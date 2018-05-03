# MethodFinder

[![Build Status](https://travis-ci.org/citizen428/methodfinder.svg)](https://travis-ci.org/citizen428/methodfinder)
[![Gem Version](https://img.shields.io/gem/v/methodfinder.svg)](https://rubygems.org/gems/methodfinder)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Warning](#warning)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [MethodFinder.find](#methodfinderfind)
  - [Object#find_method](#objectfind_method)
    - [Blacklists](#blacklists)
  - [MethodFinder.find_classes_and_modules](#methodfinderfind_classes_and_modules)
  - [MethodFinder.find_in_class_or_module](#methodfinderfind_in_class_or_module)
  - [Troubleshooting](#troubleshooting)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This project was originally inspired by Smalltalk's Method Finder, but
additional features were added over time.

## Warning

Common sense not included!

While I never had any problems with this, it's still better to be safe than
sorry, so use this with caution and maybe not on production data.

I initially wrote this for the students of the core Ruby course on
[RubyLearning](http://rubylearning.org), so Rails is not of interest to me (not
saying it doesn't work there, just that I test in plain IRB/Pry and not with
the Rails console.

## Requirements

Ruby 1.9.3+ (also works with Rubinius in 1.9 mode). Versions of `MethodFinder`
up to 1.2.5 will also work with Ruby 1.8.7. Note: CI only runs newer versions
of Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'methodfinder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install methodfinder

## Usage

### MethodFinder.find

Provided with a receiver, the desired result and possibly some arguments,
`MethodFinder.find` will list all methods that produce the given result when
called on the receiver with the provided arguments.

```ruby
MethodFinder.find(10, 1, 3)
#=> ["Fixnum#%", "Fixnum#<=>", "Fixnum#>>", "Fixnum#[]", "Integer#gcd", "Fixnum#modulo", "Numeric#remainder"]
MethodFinder.find("abc", "ABC")
#=> ["String#swapcase", "String#swapcase!", "String#upcase", "String#upcase!"]
MethodFinder.find(10, 100, 2)
#=> ["Fixnum#**"]
MethodFinder.find(['a', 'b', 'c'], ['A', 'B', 'C']) { |x| x.upcase }
#=> ["Array#collect", "Array#collect!", "Enumerable#collect_concat", "Enumerable#flat_map", "Array#map", "Array#map!"]
```

### Object#find_method

This gem also adds `Object#find_method`, which besides offering an alternative
interface to pretty much the same functionality as `MethodFinder.find`, also
allows you to test for state other than the return value of the method.

```ruby
%w[a b c].find_method { |a| a.unknown(1) ; a == %w[a c] }
#=> ["Array#delete_at", "Array#slice!"]
10.find_method { |n| n.unknown(3) == 1 }
#=> ["Fixnum#%", "Fixnum#<=>", "Fixnum#>>", "Fixnum#[]", "Integer#gcd", "Fixnum#modulo", "Numeric#remainder"]
```

Inside `find_method`'s block, the receiver is available as block argument and
the special method `unknown` is used as a placeholder for the desired method.

You can also call `find_method` without passing a block. This is the same as
calling `MethodFinder.find`.

```ruby
10.find_method(1, 3)
#=> ["Fixnum#%", "Fixnum#<=>", "Fixnum#>>", "Fixnum#[]", "Integer#gcd", "Fixnum#modulo", "Numeric#remainder"]
```

#### Blacklists

You can exclude methods from being tried by editing the hashes
`MethodFinder::INSTANCE_METHOD_BLACKLIST` and
`MethodFinder::CLASS_METHOD_BLACKLIST`. Both use the class/module as key and
an array of method names as values (note that class, module and method names
have to be symbols).

For example, to blacklist the instance method `shutdown` of `Object`, you
would do

```ruby
MethodFinder::INSTANCE_METHOD_BLACKLIST[:Object] << :shutdown
```

This might come in handy when using `MethodFinder` together with other gems as
such as `interactive_editor`.

### MethodFinder.find_classes_and_modules

A simple method to return all currently defined modules and classes.

```ruby
MethodFinder.find_classes_and_modules
#=> [ArgumentError, Array, BasicObject, Bignum ... ZeroDivisionError]
```

### MethodFinder.find_in_class_or_module

Searches for a given name within a class. The first parameter can either be a
class object, a symbol or a string whereas the optional second parameter can
be a string or a regular expression:

```ruby
MethodFinder.find_in_class_or_module('Array', 'shuff')
#=> [:shuffle, :shuffle!]
MethodFinder.find_in_class_or_module(Float, /^to/)
#=> [:to_f, :to_i, :to_int, :to_r, :to_s]
```

If the second parameter is omitted, all methods of the class or module will be
returned.

```ruby
MethodFinder.find_in_class_or_module(Math)
#=> [:acos, :acosh, :asin ... :tanh]
```

### Troubleshooting

If the `METHOD_FINDER_DEBUG` environment variable is set, the name of each
candidate method is printed to `STDERR` before it is invoked. This can be useful
to identify (and blacklist) misbehaving methods.

It can be set on the command line e.g.:

```
$ METHOD_FINDER_DEBUG=1 irb
```

Or you can toggle it inside IRB/Pry:

```ruby
>> MethodFinder.toggle_debug!
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/citizen428/methodfinder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

