Description
---

This project was originally inspired by Smalltalk's Method Finder, but
additonal features were added over time.

Usage
---

### MethodFinder.find

Provided with a receiver, the desired result and possibly some
arguments, `MethodFinder.find` will list all methods that produce the
given result when called on the receiver with the provided arguments.

    >> MethodFinder.find(10,1,3)
    => [:%, :<=>, :>>, :[], :modulo, :remainder]
    >> MethodFinder.find("abc","ABC")
    => [:swapcase, :swapcase!, :upcase, :upcase!]
    >> MethodFinder.find(10,100,2)
    => [:**]
    >> MethodFinder.find(['a','b','c'],['A','B','C']) { |x| x.upcase }
    => [:collect, :collect!, :map, :map!]

### Object#find_method

This gem also adds `Object#find_method`, which besides offering an
alternate interface to pretty much the same functionality as
`MethodFinder.find`, also allows you to test for state other than
the return value of the method. 

    >> %w[a b c].find_method { |a| a.unknown(1) ; a == %w[a c] }
    => [:delete_at, :slice!]
    >> 10.find_method { |n| n.unknown(3) == 1 }
    => [:%, :<=>, :>>, :[], :gcd, :modulo, :remainder]

Inside `find_method`'s block, the receiver is available as block
argument and the special method `unknown` is used as a placeholder for
the desired method.

### MethodFinder.find\_classes\_and_modules

A simple method to return all currently defined modules and classes.

    >> MethodFinder.find_classes_and_modules
    => [ArgumentError, Array, BasicObject, Bignum ... ZeroDivisionError] 

### MethodFinder.find\_in\_class\_or_module

Searches for a given name within a class. The first parameter can
either be a class object, a symbol or a string whereas the optional
second parameter can be a string or a regular expression:

    >> MethodFinder.find_in_class_or_module('Array', 'shuff')
    => [:shuffle, :shuffle!]
    >> MethodFinder.find_in_class_or_module(Float, /^to/)
    => [:to_f, :to_i, :to_int, :to_r, :to_s]

If the second parameter is omitted, all methods of the class or module
will be returned.

    >> MethodFinder.find_in_class_or_module(Math)
    => [:acos, :acosh, :asin ... :tanh]

Warning
---

Common sense not included!

While I never had any problems with this, it's still better to be
safe than sorry, so use this with caution and maybe not on production
data. 

I initially wrote this for the students of the core Ruby course on
[RubyLearning](http://rubylearning.org), so Rails is not of interest
to me (not saying it doesn't work there, just that I test in plain
IRB, not with `script/console`).  

Todo
---

* a method black list (maybe)

Thanks
---

* Matthew Lucas for first packaging this as a gem.
* Ryan Bates for
[suggesting](https://github.com/citizen428/methodfinder/issues/closed#issue/3)
what eventually became `Object#find_method`.

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
