## Better Composition With
# [fit] Traits

## [fit] Joe Corcoran · [corcoran.io](http://corcoran.io) · [@josephcorcoran](http://twitter.com/josephcorcoran)

---

```ruby
class Bike
  def wheels; 2 end
end
```

^ Let's build a bike. Given that all bikes start with basically the same features, we'll create a basic bike class.

---

```ruby
class Bike
  def wheels; 2 end
end

class Track < Bike
  def gearing; :fixed end
  def brakes; [] end
end
```

^ Let's make a new bike that inherits from our basic bike class. A track bike has fixed gearing and no brakes.

---

```ruby
class Bike
  def wheels; 2 end
end

class Track < Bike
  def gearing; :fixed end
  def brakes; [] end
end

track = Track.new
track.wheels  # => 2
track.gearing # => :fixed
track.brakes  # => []
```

^ Works as expected.

---

```ruby
class Track < Bike
  def gearing; :fixed end
  def brakes; [] end
end

class Fixie < Track
  def brakes; [:front, :back] end
end
```

^ I want my fixie to look like a nice track bike, but I need brakes for riding around the city – I don't want to crash.

---

```ruby
class Track < Bike
  def gearing; :fixed end
  def brakes; [] end
end

class Fixie < Track
  def brakes; [:front, :back] end
end

fixie = Fixie.new
fixie.wheels  # => 2
fixie.gearing # => :fixed
fixie.brakes  # => [:front, :back]
```

^ Works as expected too. But we're three classes in and already we are making a bit of a mess. We're forced into building a hierarchy. Hierarchies can be rigid and hard to undo. Often they don't reflect the world we are trying to model either. Not everything is a tree!

---

# [fit] Composition

^ Let's try composition.

---

> Prefer composition over inheritance.
-- Somebody

^ I don't know who said this first, but it's a kind of mantra in the Ruby world now.

---

```ruby
module Bike
  def wheels; 2 end
end

module Track
  def gearing; :fixed end
  def brakes; [] end
end

class Fixie
  include Bike
  include Track

  def brakes; [:front, :back] end
end
```

^ Here's the same code written in a composed instead of single inheritance. This feels better. Bikes are essentially made up of components and we are reflecting that. We're no longer bound to the hierarchy that single inheritance forced on us.

---

# [fit] But

---

```ruby
module Bike
  def wheels; 2 end
  def brakes; [:front, :back] end
end

module Track
  def gearing; :fixed end
  def brakes; [] end
end

class Fixie
  include Bike
  include Track
end

fixie = Fixie.new
fixie.brakes # => ?
```

^ Let's change things slightly. What if we had this setup? Let's assume that most bikes have two brakes, so it's safe to define the `#brakes` method like this in our Bike module. Both modules now both provide a `#brakes` method.

---

```ruby
module Bike
  def wheels; 2 end
  def brakes; [:front, :back] end
end

module Track
  def gearing; :fixed end
  def brakes; [] end
end

class Fixie
  include Bike
  include Track
end

fixie = Fixie.new
fixie.brakes # => []
```

^ There is no explicit way to say "give me the following methods from this module", so we rely on Ruby's implicit ordering of ancestors. Fixie gets its #brakes method from Track because Track was included last.

---

```ruby
Fixie.ancestors

# => [Fixie, Track, Bike, Object, ...]
```

^ Ruby achieves multiple inheritance by inserting the modules into the ancestor chain. Whichever module was included last, takes precedence.

---

# Problems

---

# Problems
* Implied design

^ There is application logic buried in implied behaviour, rather than clearly stated.

---

# Problems
* Implied design
* Maintenance is harder

^ Developers who are new to the project might miss our intentions completely and break things. We might even forget our own intentions and break things ourselves at some time in the future.

---

# Problems
* Implied design
* Maintenance is harder
* We need tests to cover our basic design

^ Do we really want to test such basic things?

---

# [fit] The diamond problem

^ If you dig into this topic, you'll come across the famous Diamond Problem. It's very similar to what we just worked through.

---

![](diamond.png)

^ This is more of a concrete problem in languages where memory allocation and actually copying class members are concerns. But it's still a higher level code clarity problem in Ruby.

---

> Multiple inheritance is good, but there is no good way to do it.
-- Steve Cook

^ I don't know that much about Steve Cook, apart from that he worked at IBM and Microsoft and that he's a fairly old-school object-oriented programmer. When he wrote this, he was summarizing a conversation from a conference in which people agreed that multiple inheritance was a great paradigm in theory but nobody had yet come up with a way of doing it without introducing further problems.

---

# [fit] Traits

---

# Traits: A Mechanism for Fine-grained Reuse
## Ducasse, Nierstrasz, Schärli, Wuyts and Black
### Software Composition Group<br>University of Berne, 2006
---

# Traits
* Finite method dictionaries

^ They provide a number of methods, much like a Ruby module.

---

# Traits
* Finite method dictionaries
* Composable

^ Just as we can compose classes with traits, we can compose traits with other traits.

---

# Traits
* Finite method dictionaries
* Composable
* Can be summed with other traits

^ Traits are "summed" by "taking the union of non-conflicting methods and disabling the conflicting methods".

---

$$
a \to m1
$$

^ Maths! This is a method. It has a name, "a", and a method body, "m1".

---

$$
\{a \to m1\}
$$

^ This is a method dictionary. It's just a set containing the previous method.

---

$$
\{a \to m1, b \to m2\} + \{a \to m1, b \to m3\} = \{a \to m1, b \to \top\}
$$

^ Here is a demonstration of composing two method dictionaries and getting a method conflict. Notice that in both sets, `a` refers to the same method body `m1`, so there's no conflict. But `b` refers to two different method bodies, `m2` and `m3`, so we cannot resolve the union of these two sets. The `T` symbol there usually means "top", but in this paper it's just used to refer to any method conflict. The reason I included the last three slides is not to intimidate people with maths, but to demonstrate that the mathematical notation in this paper is straightforward. If you understood this, you can jump in and read the rest of the paper without any problems. Go for it!

---

# Resolving conflicts

---

# Resolving conflicts
* Override the conflicting method

^ When we compose a class with two traits, and two methods clash, we can just add a method to the composing class with the same name and it takes precedence.

---

# Resolving conflicts
* Override the conflicting method
* Exclude methods

^ We just say "give me all the methods from this trait, except #foo". Inclusion would work too, but it would be very verbose.

---

# Resolving conflicts
* Override the conflicting method
* Exclude methods
* Alias methods

^ We say "give me all of the methods from this trait, but rename #foo to #bar".

---

# Flattening

---

# Flattening
* A *well-defined* class...

^ A typically academic term...

---

# Flattening
* A *well-defined* class has no conflicting methods after composition

^ ...which basically means that there are no conflicts after composition.

---

# Flattening
* A *well-defined* class has no conflicting methods after composition
* No need for traits!

^ No conflicts means we don't need any kind of inheritance at all – we can simply "flatten" the class, meaning we can do away with method lookup through ancestors completely. Traits used correctly are self-defeating – they don't want to exist! It's a weird concept, but what it means in practice is that we can provide multiple inheritance by eliminating inheritance completely at the composition stage.

---

# [fit] Scala

---

```scala
trait Bike {
  def wheels() : Int = {
    return 2
  }
  def brakes() : Vector[Symbol] = {
    return Vector('front, 'back)
  }
}

trait Track {
  def gearing() : Symbol = {
    return 'fixed
  }
  def brakes() : Vector[Symbol] = {
    return Vector()
  }
}

class Fixie extends Bike with Track {}
```

^ Scala has traits. Here's our bike example from earlier, implemented in Scala.

---

```scala
trait Bike {
  def wheels() : Int = {
    return 2
  }
  def brakes() : Vector[Symbol] = {
    return Vector('front, 'back)
  }
}

trait Track {
  def gearing() : Symbol = {
    return 'fixed
  }
  def brakes() : Vector[Symbol] = {
    return Vector()
  }
}

class Fixie extends Bike with Track {}
// => error: class Fixie inherits conflicting members
```

^ There's no implicit last-include-wins in Scala, so our program blows up when two traits provide methods with the same name.

---

```scala
trait Bike {
  def wheels() : Int = {
    return 2
  }
  def brakes() : Vector[Symbol] = {
    return Vector('front, 'back)
  }
}

trait Track {
  def gearing() : Symbol = {
    return 'fixed
  }
  def brakes() : Vector[Symbol] = {
    return Vector()
  }
}

class Fixie extends Bike with Track {
  override def brakes() : Vector[Symbol] = {
    return Vector('front, 'back)
  }
}
```

^ The way we fix this is to override the method in the composing class, using the override keyword.

---

```ruby
module Bike
  def wheels; 2 end
  def brakes; [:front, :back] end
end

module Track
  def gearing; :fixed end
  def brakes; [] end
end

class Fixie
  include Bike
  include Track
end
```

^ Back to our Ruby bikes. This was as far as we got earlier on.

---

```ruby
module Bike
  def wheels; 2 end
  def brakes; [:front, :back] end
end

module Track
  def gearing; :fixed end
  def brakes; [] end
end

class Fixie
  compose Bike,
          Track.methods(exclude: :brakes)
end
```

^ What if we had a way of explicitly saying "here are the traits I want to compose"? What if we could compose modules properly instead of just shoving them into the ancestor chain?

---

```ruby
source 'https://rubygems.org'

gem 'fabrik'
```

^ Well we can, because I wrote this! In your Gemfile...

---

```ruby
class Bike
  extend Fabrik::Trait

  provides do
    def wheels; 2 end
    def brakes; [:front, :back] end
  end
end

class Track
  extend Fabrik::Trait

  provides do
    def gearing; :fixed end
    def brakes; [] end
  end
end

class Fixie
  extend Fabrik::Composer

  compose Bike,
          Track[exclude: :brakes]
end
```

^ Here's what the bikes look like with Fabrik. We've changed the trait modules into classes and extended `Fabrik::Trait`. In the composing class we've just extended `Fabrik::Composer`. All of the methods that a trait provides are defined inside the `provides` block. There's also a shortcut `[]` method for conflict resolution when composing traits.

---

```ruby
class Fixie
  extend Fabrik::Composer

  compose Bike,
          Track[aliases: { brakes: :stopping_machines }]
end
```

^ Here's what aliasing a method looks like.

---

```ruby
class Fixie
  extend Fabrik::Composer

  def brakes; [:front] end

  compose Bike, Track
end
```

^ Methods that are defined before composition take precedence over any methods provided by traits. This feels a bit rough, but Ruby is so permitting that I didn't feel like fighting it. :)

---

```ruby
class Bike
  extend Fabrik::Trait

  provides do
    def wheels; 2 end
    def brakes; [:front, :back] end
  end
end
```

^ So, about this `provides` method. The reason it exists is because of a cool trick that we can do in Ruby 2. Each trait class in Fabrik contains its own anonymous module, and all the methods inside `provides` are defined on this module.

---

```ruby
module Foo
  def bar; :baz end
end

bar = Foo.instance_method(:bar)
# => #<UnboundMethod: Foo#bar>
```

^ We can reach into a module, grab an instance method and turn it into an `UnboundMethod`.

---

```ruby
module Foo
  def bar; :baz end
end

bar = Foo.instance_method(:bar)

class Qux; end
Qux.send(:define_method, :quux, bar)

Qux.new.quux
# => :baz
```

^ We can then pass that unbound method to `define_method`, defining it on another class! This is basically how Fabrik works.

---

```ruby
module Foo
  def bar; :baz end
end

bar = Foo.instance_method(:bar)

class Qux; end
Qux.send(:define_method, :quux, bar)
# => TypeError: bind argument must be a subclass of Foo
```

---

$$
\{a \to m1, b \to m2\} + \{a \to m1, b \to m3\} = \{a \to m1, b \to \top\}
$$

^ Remember this? We said a conflict arises if two traits provide the same method body with the same name. Fabrik treats `UnboundMethod`s as method bodies, to use the terminology of the paper.

---

```ruby
module Foo
  def bar; :baz end
end

b1 = Foo.instance_method(:bar)
b2 = Foo.instance_method(:bar)

b1 == b2 # => true
```

^ Ruby has already decided what it means for two `UnboundMethod`s to be equal, and thankfully they can have different `object_id`s. So we can use this to good effect when composing traits.

---

```ruby
module Foo
  def bar; :baz end
end

class Qux
  extend Fabrik::Trait
  provides_from Foo, :bar
end
```

^ `#provides_from` takes a list of methods from any module and includes them in a trait.

---

```ruby
module Paintwork
  def paint!
    [:red, :green, :blue].sample
  end
end

class Bike
  extend Fabrik::Trait
  provides_from Paintwork, :paint!
end

class Track
  extend Fabrik::Trait
  provides_from Paintwork, :paint!
end

class Fixie
  extend Fabrik::Composer
  compose Bike, Track
end

fixie = Fixie.new
fixie.paint! # => :green
```

^ So let's look at a different example. Because the `#paint!` method provided by both traits is *the same*, we can compose without conflicts!

---

# Links

* [Traits: A Mechanism for Fine-grained Reuse (PDF)](http://scg.unibe.ch/archive/papers/Duca06bTOPLASTraits.pdf)
* [github.com/joecorcoran/fabrik](https://github.com/joecorcoran/fabrik)
* [github.com/joecorcoran/talks/tree/master/traits](https://github.com/joecorcoran/talks/tree/master/traits)

* [corcoran.io](http://corcoran.io)
* [@josephcorcoran](http://twitter.com/josephcorcoran)
