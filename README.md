# DurableDecorator

![Quick Summary](http://cdn.memegenerator.net/instances/300x300/38628144.jpg)

[![Build Status](https://travis-ci.org/jumph4x/durable_decorator.png)](https://travis-ci.org/jumph4x/durable_decorator)
[![Code Climate](https://codeclimate.com/github/jumph4x/durable_decorator.png)](https://codeclimate.com/github/jumph4x/durable_decorator)
[![Dependency Status](https://gemnasium.com/jumph4x/durable_decorator.png)](https://gemnasium.com/jumph4x/durable_decorator)

This is a project for modifying the behavior of gems outside of your reach. You may be using a large Rails Engine and be wanting to simply decorate some existing behavior, but at the same time you want to inherit original behavior. 

## On tracking new decorators and managing fragility

After a lovely and short discussion with [Brian Quinn](https://github.com/BDQ) regarding these ideas, he mentioned we could try hashing methods to be able to raise warnings upon unexpected sources or targets (see his work on [Deface](https://github.com/spree/deface)). This project relies on another lovely meta-programming creation by [John Mair](https://github.com/banister), specifically his work on [method_source](https://github.com/banister/method_source).

Some additional background: http://stackoverflow.com/questions/4470108/when-monkey-patching-a-method-can-you-call-the-overridden-method-from-the-new-i

## Installation

Add this line to your application's Gemfile:

    gem 'durable_decorator', github: 'jumph4x/durable_decorator'

Or to include rake tasks for Rails you can use [DurableDecoratorRails](https://github.com/jumph4x/durable_decorator_rails):

    gem 'durable_decorator_rails', github: 'jumph4x/durable_decorator_rails'

And then execute:

    $ bundle

## UPGRADING

Prior to Version 0.2.0 original methods would have a suffix of original or SHA.  A recent change has been made to
use prefix rather than suffix in order to be compatible with example! and example? methods.  Please review your durably decorated
methods when upgrading to Version 0.2.0.

Versions >= 0.2.0 are not tested on Rubies < 1.9.2. Please use version 0.1.2 if you absolutely need Ruby 1.8.7 compatibility.

## Usage

```ruby
class ExampleClass
  def string_method
    "original"
  end
end

ExampleClass.class_eval do
  durably_decorate :string_method do
    original_string_method + " and new"
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
  durably_decorate :string_method, mode: 'strict', sha: 'WRONG-SHA-123456' do
    original_string_method + " and new"
  end
end

DurableDecorator::TamperedDefinitionError: Method SHA mismatch, the definition has been tampered with
```

DurableDecorator may also decorate methods with params like so:

```ruby
class ExampleClass
  def string_method(text)
    "original #{text}"
  end
end

ExampleClass.class_eval do
  durably_decorate :string_method, mode: 'strict', sha: 'ba3114b2d46caa684b3f7ba38d6f74b2' do |text|
    original_string_method(text) + " and new"
  end
end

instance = ExampleClass.new
instance.string_method('test')
# => "original test and new"
```

DurableDecorator also maintains explicit versions of each method overriden by creating aliases with prepended SHAs of the form ```_1234abcd_some_method``` so you can always target explicit method versions without relying on ```original_some_method```.

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
# 4-char SHA, 6-char SHA and the full SHA prefix

instance = ExampleClass.new
instance._ba31_string_method
# => "original"
instance._ba3114_string_method
# => "original"
instance._ba3114b2d46caa684b3f7ba38d6f74b2_string_method
# => "original"
```

### Asking for history

You can inquire about the history of method [re]definitions like this:
```ruby
DurableDecorator::Base.definitions('ExampleClass#one_param_method')
# => [{:name=>:one_param_method, :sha=>"935888f04d9e132be458591d5755cb8131fec457", :body=>"def one_param_method param\n  \"original: \#{param}\"\nend\n", :source=>["/home/denis/rails/durable_decorator/spec/example_class.rb", 6]}, {:name=>:one_param_method, :sha=>"3c39948e5e83c04fd4bf7a6ffab12c6828e0d959", :body=>"durably_decorate :one_param_method do |another_string|\n  \"\#{one_param_method_935888f04d9e132be458591d5755cb8131fec457('check')} and \#{another_string}\"\nend\n", :source=>["/home/denis/rails/durable_decorator/spec/durable_decorator_spec.rb", 45]}] 
```

With any luck you can even get the specific [re]definition printed!
```ruby
puts DurableDecorator::Base.definitions('ExampleClass#one_param_method')[0][:body]
def one_param_method param
  "original: #{param}"
end
```

### No more surprise monkey patching
Once you decorate the method and seal it with its SHA, if some gem tries to come in and overwrite your work **BEFORE** decorate-time, DurableDecorator will warn you. Similarly, expect to see an exception bubble up if the definition of the original method has changed and requires a review and a re-hash. 

The usefulness is for gem consumers, and their application-level specs. 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
