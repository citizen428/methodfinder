const std = @import("std");
const assert = std.debug.assert;

const stdx = @import("./stdx/stdx.zig");
const Shell = stdx.Shell;

pub fn main() !void {
    var gpa_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_allocator.deinit();

    const gpa = gpa_allocator.allocator();

    const shell = try Shell.create(gpa);
    defer shell.destroy();

    const token = try publish_ruby_trusted_publishing_token(shell);
    assert(token.len > 0);
}

fn publish_ruby_trusted_publishing_token(shell: *Shell) ![]const u8 {
    const trusted_publishing_token = try shell.env_get("ACTIONS_ID_TOKEN_REQUEST_TOKEN");
    const trusted_publishing_url = try shell.env_get("ACTIONS_ID_TOKEN_REQUEST_URL");

    const oidc_response = try shell.http_get(
        try shell.fmt("{s}&audience={%}", .{
            trusted_publishing_url,
            std.Uri.Component{ .raw = "rubygems.org" },
        }),
        .{
            .authorization = try shell.fmt("bearer {s}", .{trusted_publishing_token}),
        },
    );
    const oidc = try std.json.parseFromSliceLeaky(
        struct { value: []const u8 },
        shell.arena.allocator(),
        oidc_response,
        .{ .ignore_unknown_fields = true },
    );

    try dump_oidc_claims(shell, oidc.value);

    const rubygems_request = try std.json.stringifyAlloc(
        shell.arena.allocator(),
        .{ .jwt = oidc.value },
        .{},
    );
    const rubygems_response = try shell.http_post(
        "https://rubygems.org/api/v1/oidc/trusted_publisher/exchange_token",
        rubygems_request,
        .{ .content_type = .json },
    );
    const rubygems = try std.json.parseFromSliceLeaky(
        struct { rubygems_api_key: []const u8 },
        shell.arena.allocator(),
        rubygems_response,
        .{ .ignore_unknown_fields = true },
    );

    return rubygems.rubygems_api_key;
}

fn dump_oidc_claims(shell: *Shell, jwt: []const u8) !void {
    var parts = std.mem.splitScalar(u8, jwt, '.');
    _ = parts.next() orelse return error.InvalidJWT;
    const payload_encoded = parts.next() orelse return error.InvalidJWT;
    _ = parts.next() orelse return error.InvalidJWT;
    if (parts.next() != null) return error.InvalidJWT;

    const padding = (4 - (payload_encoded.len % 4)) % 4;
    const payload_base64 = try shell.arena.allocator().alloc(
        u8,
        payload_encoded.len + padding,
    );
    for (payload_encoded, 0..) |byte, i| {
        payload_base64[i] = switch (byte) {
            '-' => '+',
            '_' => '/',
            else => byte,
        };
    }
    @memset(payload_base64[payload_encoded.len..], '=');

    const payload_len = try std.base64.standard.Decoder.calcSizeForSlice(payload_base64);
    const payload_json = try shell.arena.allocator().alloc(u8, payload_len);
    try std.base64.standard.Decoder.decode(payload_json, payload_base64);

    const claims = try std.json.parseFromSliceLeaky(
        struct {
            iss: ?[]const u8 = null,
            aud: ?[]const u8 = null,
            repository: ?[]const u8 = null,
            repository_owner: ?[]const u8 = null,
            repository_owner_id: ?[]const u8 = null,
            environment: ?[]const u8 = null,
            job_workflow_ref: ?[]const u8 = null,
            ref: ?[]const u8 = null,
            sha: ?[]const u8 = null,
            sub: ?[]const u8 = null,
        },
        shell.arena.allocator(),
        payload_json,
        .{ .ignore_unknown_fields = true },
    );

    var stdout_buffer = std.io.bufferedWriter(std.io.getStdOut().writer());
    const stdout = stdout_buffer.writer();
    try std.json.stringify(claims, .{ .whitespace = .indent_2 }, stdout);
    try stdout.writeByte('\n');
    try stdout_buffer.flush();
}
