# [fit] Ruby on Rust

Joe Corcoran • [corcoran.io](https://corcoran.io) • [@josephcorcoran](http://twitter.com/josephcorcoran)

---

# What?

^ Calling dynamic library functions from Ruby.

---

# What is a dynamic library?

^ A compiled library that is intended for sharing with other libraries or programs.

---

# Why shared libraries?

^ Shared libraries are nice because they help us to avoid reinventing the wheel. If a known, good quality library for, say, hashing exists, we should use it instead of trying to write an equivalent implementation. 

---

# Why in Ruby?

^ In Ruby, it's common to rely on libraries written in C when speed is essential. Since Ruby is written in C, interoperability has always been possible by simply using the underlying C functions that Ruby itself uses to create Ruby objects. However,  if we just want to call functions from existing libraries, we have libffi.

---

# libffi

* Foreign function interface
* Created in 1996
* Commonly used to connect compiled -> interpreted languages

---

# `DL`

```ruby
module Something
  extend DL::Importer
  dlload './something.so'
  extern 'int foo(int)'
end
```

^ Been around since 2002. Used internally for a long time. Useful but limited in scope, required the user to be happy at a low level. Bad UX, perceived as buggy, eprecated, disappeared as of Ruby 2.2.

---

> Ruby already has a library called DL... [it] is a bit arcane though...
-- [rubyinside.com/ruby-ffi-library-calling-external-libraries-now-easier-1293.html](http://www.rubyinside.com/ruby-ffi-library-calling-external-libraries-now-easier-1293.html)

^ FFI was released in 2008 by Wayne Meissner. A libffi wrapper with bigger goals. Nice to look back at the excited announcement from RubyInside.

---

# `FFI`

[github.com/ffi/ffi](https://github.com/ffi/ffi)

```ruby
module Something
  extend FFI::Library
  ffi_lib './something.so'
  attach_function :foo, [:int], :int
end
```

^ FFI provided the same basics as DL but added extra funtionality; cross-platform support and cross-Ruby support (MRI, JRuby, Rubinius). Made it easier to work with structs, arrays etc.

---

# `FFI`

```ruby
pointer = FFI::MemoryPointer.new(8)
pointer.write_array_of_int([1, 2])
pointer.read_array_of_int(2)
#=> [1, 2]
```

^ The FFI gem also provides a nice interface for abstracting pointer arithmetic – the most error-prone and potentially annoying part of interfacing between Ruby and C.

---

# `Fiddle`

```ruby
module Something
  extend Fiddle::Importer
  dlload './something.so'
	extern 'int foo(int)'
end
```

^ Provides the same importer functionality as DL, but adds stability. Overall user experience is still not on a par with FFI, frankly, but using Fiddle will teach you more about pointers, memory allocation etc., which is why I recommend it to other learners.

---

# Rust
## libc

```rust
extern crate libc;
```

^ Rust has a packaging system, like Bundler, named Cargo. The equivalent of a gem is a crate. Ruby can speak to C, but not to Rust. Here we use the libc crate, which gives us access to bunch of stuff that helps our Rust code stay compatible with C.

---

# Rust
## libc

```rust
extern crate libc;

use libc::c_int;
```

^ We also have to declare which bits of the crate we're actually going to use. In our case, it's only c_int, which is an integer type.

---

# Rust
## Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    // tests go here
}
```

^ It's common to write tests in the same file as your library in Rust, and I must say I enjoy this a lot, coming from Ruby with our many weirdly-organized directories. Note the conditional compilation attribute above the tests module. Test modules have no access to the library code, so we can be sure they behave like an end-user. We can include all of the public stuff from the enclosing module with super::*.

---

# Integers
## Rust

```rust
#[no_mangle]
pub extern fn add_one(a: c_int) -> c_int {
    a + 1
}
```

^ Okay. Here's our first basic Rust function that can be used as if it was a C function. The no_mangle attribute tells the Rust compiler that it should not obscure the function name. We want to call add_one from another language, so that symbol in the compiled code must be accessible. pub means public, as in usable from outside this module. The extern keyword can be followed by a string that explains which interface we're aiming for. "C" is the default, so it's omitted here.

---

# Integers
## Rust

```rust
#[no_mangle]
pub extern fn add_one(a: c_int) -> c_int {
    a + 1
}

#[test]
fn test_add_one() {
    assert_eq!(2, add_one(1));
}
```

^ Here's a little test for our function. Bear in mind I've left out the test module boilerplate for space reasons. Test functions are marked as such with another attribute.

---

# Integers
## Rust

```
$ cargo test

running 1 test
test tests::test_add_one ... ok
test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured
```

^ We run Rust tests via cargo.

---

# Integers
## Rust

```
$ cargo build --release
```

^ Time to compile our library. cargo build usually runs in debug mode, which outputs to the debug directory. But for the sake of having a consistent path to our library to reference from within Ruby, we'll skip to compiling in release mode.

---

# Integers
## Ruby

```ruby
require 'fiddle'
lib = Fiddle.dlopen(
  File.expand_path('../rust/target/release/libfoo.so', __FILE__)
)

add_one = Fiddle::Function.new(
  lib['add_one'],
  [Fiddle::TYPE_INT],
  Fiddle::TYPE_INT
)

add_one.call(1)   #=> 2
```

^ Here's where it gets interesting! Using Fiddle, we can create a handle on the shared library we just compiled. The handle gives us access to all of the public functions in the library via hash syntax. So we can create a function object. We specify that the function accepts one integer and returns one integer. The Fiddle TYPE_ constants map to C types. The resulting function object is not a Ruby method, but an object that responds to call. It works!

---

# Arrays
## Rust

```rust
#[repr(C)]
pub struct IntArray {
    length: c_int,
    members: *const c_int
}
```

^ Arrays are another story. It's easy to forget if you work with Ruby a lot, just how convenient it is to sling arrays around like we do. In lower level languages, like Rust, we need to be a lot more strict. We need to care about what an array contains, and how it will be represented in memory. One way of doing this is to define a struct that will represent an array. Our struct here works with arrays of integers only. The array struct consists of a length and a raw pointer. Rust encourages us to stay away from raw pointers whenever we can, but since we're calling this from Ruby, we don't have that luxury.

---

# Arrays
## Ruby

```ruby
require 'fiddle/struct'

IntArray = Fiddle::CStructBuilder.create(
  Fiddle::CStruct,
  [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP],
  ['length', 'members']
)
```

^ Here's the array struct on the Ruby side. Fiddle gives us a struct builder class, and we can repeat what we did in Rust. The struct has an integer to represent the array length, and a pointer.

---

# Arrays
## Rust

```rust
use std::slice;

#[no_mangle]
pub extern fn head(a: &IntArray) -> c_int {
    unsafe {
        let slice = slice::from_raw_parts(a.members, a.length as usize);
        *slice.first().unwrap()
    }
}
```

^ So, on to the function implementation. Our function accepts an IntArray. Or rather, it accepts a borrowed reference to a IntArray. This means that the function a. can't modify it and b. will not deallocate the memory when it goes out of scope. Ownership is a big concept in Rust and too detailed to go into tonight, but once you play around with Rust you'll get a better feel for it. I'm still learning. Next you'll see that unsafe block. Whenever we work with raw pointers, Rust forces us to admit that the code is unsafe. So mean! But it actually means: don't apply your strict safety checking to this section of code. And we really need to say that, since working with raw pointers can easily go wrong. Next we create a slice from the raw pointer, which is where our length value comes in handy. A slice is another borrowed... thing. Think of it here as a view into an array or list. The last line, which also sets the return value of the function, is bad code. But it's slide-friendly! first returns an Option type and we're choosing to simply unwrap it, which would explode if the slice was empty.

---

# Arrays
## Ruby

```ruby
head = Fiddle::Function.new(
  lib['head'],
  [Fiddle::TYPE_VOIDP],
  Fiddle::TYPE_INT
)
```

^ Function def.

---

# Arrays
## Ruby

```ruby
array = [3, 2, 1]
packed = IntArray.malloc
packed.length = array.length
packed.members = array.pack('l*')

head.call(packed)   #=> 3
```

^ Packs the Ruby array into memory.

---

# More information

* [github.com/joecorcoran/talks](https://github.com/joecorcoran/talks/tree/master/noenv)
* [Using Rust with Ruby, a deep dive with Yehuda Katz](https://www.youtube.com/watch?v=IqrwPVtSHZI)
* [github.com/steveklabnik/rust_example](https://github.com/steveklabnik/rust_example)
* [rust-lang.org](https://www.rust-lang.org/)

^ Mention C bridges into Rubygems, extconf.rb