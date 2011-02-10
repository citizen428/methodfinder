Description
---

A Smalltalk-like Method Finder for Ruby. Provided with a receiver, a
desired result and possibly some arguments, it will list all methods
that produce the result when called on the receiver with the arguments.

Usage
---

    >> Methodfinder.find(10,1,3)
    => [:%, :<=>, :>>, :[], :modulo, :remainder]
    >> MethodFinder.find("abc","ABC")
    => [:swapcase, :swapcase!, :upcase, :upcase!]
    >> MethodFinder.find(10,100,2)
    => [:**]
    >> MethodFinder.find(['a','b','c'],['A','B','C']) { |x| x.upcase }
    => [:collect, :collect!, :map, :map!]

Todo
---

* Redirect `stdout` and `stderr` to a StringIO object instead of `/dev/null` unless someone tells me that the latter works on Windows. 
* Maybe add some sort of method blacklist so they won’t get tried in the block.


Thanks
---

* Matthem Lucas for packaging it as a gem.

License
---

Copyright (c) 2011 Michael Kohl

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
