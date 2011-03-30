Description
---

A Smalltalk-like Method Finder for Ruby. Provided with a receiver, a
desired result and possibly some arguments, it will list all methods
that produce the result when called on the receiver with the arguments.

Usage
---

    >> MethodFinder.find(10,1,3)
    => [:%, :<=>, :>>, :[], :modulo, :remainder]
    >> MethodFinder.find("abc","ABC")
    => [:swapcase, :swapcase!, :upcase, :upcase!]
    >> MethodFinder.find(10,100,2)
    => [:**]
    >> MethodFinder.find(['a','b','c'],['A','B','C']) { |x| x.upcase }
    => [:collect, :collect!, :map, :map!]

Warning
---

Common sense not included!

While I never had any problems with this, it's still better to be
save than sorry, so use this with caution and maybe not on production
data. 

I initially wrote this for the students of the core Ruby course on
[RubyLearning](http://rubylearning.org), so Rails is not of interest
to me (not saying it doesn't work there, just that I test in plain
IRB, not with `script/console`).  

Todo
---

* a method black list
* maybe an alternate form of calling this (issue #3)


Thanks
---

* Matthew Lucas for packaging it as a gem.

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
