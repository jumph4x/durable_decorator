# DurableDecorator

![Quick Summary](http://cdn.memegenerator.net/instances/300x300/38628144.jpg)

[![Build Status](https://travis-ci.org/jumph4x/durable_decorator.png)](https://travis-ci.org/jumph4x/durable_decorator)
[![Code Climate](https://codeclimate.com/github/jumph4x/durable_decorator.png)](https://codeclimate.com/github/jumph4x/durable_decorator)

This is a project for modifying the behavior of gems outside of your reach. You may be using a large Rails Engine and be wanting to simply decorate some existing behavior, but at the same time you want to inherit original behavior. 

## On tracking new decorators and managing fragility

After a lovely and short discussion with [Brian Quinn](https://github.com/BDQ) regarding these ideas, he mentioned we could try hashing methods to be able to raise warnings upon unexpected sources or targets (see his work on [Deface](https://github.com/spree/deface)). This project relies on another lovely meta-programming creation by [John Mair](https://github.com/banister), specifically his work on [method_source](https://github.com/banister/method_source).

Some additional background: http://stackoverflow.com/questions/4470108/when-monkey-patching-a-method-can-you-call-the-overridden-method-from-the-new-i

## Installation

Add this line to your application's Gemfile:

    gem 'durable_decorator', :github => 'jumph4x/durable_decorator'

And then execute:

    $ bundle

## Usage

```ruby
class ExampleClass
  def string_method
    "original"
  end
end

class ExampleClass
  durably_decorate :string_method do
    string_method_original + " and new"
  end
end

instance = ExampleClass.new
instance.string_method
# => "original and new"
```

### Working with SHAs

Furthermore, we can hash the contents of a method as it exists at inspect-time and seal it by providing extra options to the decorator. If the method definition gets tampered with, the decorator will detect this at decoration-time and raise an error for your review. 

Find the SHA of the method as currently loaded into memory, works with classes as well as modules:
```ruby
DurableDecorator::Base.determine_sha('ExampleClass#instance_method')
```

Or for class (singleton) methods:
```ruby
DurableDecorator::Base.determine_sha('ExampleClass.class_level_method')
```

Armed with this knowledge, we can enforce a strict mode: 
```ruby
DurableDecorator::Base.determine_sha('ExampleClass#no_param_method')
# => 'ba3114b2d46caa684b3f7ba38d6f74b2'
ExampleClass.class_eval do
  meta = {
    mode: 'strict',
    sha: 'WE-IGNORE-THE-ABOVE'
  }

  durably_decorate :string_method, meta do
    string_method_original + " and new"
  end
end

DurableDecorator::TamperedDefinitionError: Method SHA mismatch, the definition has been tampered with
```

DurableDecorator also maintains explicit versions of each method overriden by creating aliases with appended SHAs of the form ```some_method_1234abcd``` so you can always target explicit method versions without relying on ```some_method_original```.

DurableDecorator maintains 3 versions of aliases to previous method versions, 2 of which are short-SHA versions, akin to Github:
```ruby
DurableDecorator::Base.determine_sha('ExampleClass#no_param_method')
# => 'ba3114b2d46caa684b3f7ba38d6f74b2'

ExampleClass.class_eval do
  durably_decorate :string_method do
    "new"
  end
end

# 3 explicit aliases preserve access to the original method based on it's original SHA:
# 4-char SHA, 6-char SHA and the full SHA suffix

instance = ExampleClass.new
instance.string_method_ba31
# => "original"
instance.string_method_ba3114
# => "original"
instance.string_method_ba3114b2d46caa684b3f7ba38d6f74b2
# => "original"
```

### No more suprise monkey patching
Once you decorate the method and seal it with its SHA, if some gem tries to come in and overwrite your work **BEFORE** decorate-time, DurableDecorator will warn you. Similarly, expect to see an exception bubble up if the definition of the original method has changed and requires a review and a re-hash. 

The usefulness is for gem consumers, and their application-level specs. 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
