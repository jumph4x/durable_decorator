# DurableDecorator

![Quick Summary](http://cdn.memegenerator.net/instances/300x300/38628144.jpg)

[![Build Status](https://travis-ci.org/jumph4x/durable_decorator.png)](https://travis-ci.org/jumph4x/durable_decorator)
[![Code Climate](https://codeclimate.com/github/jumph4x/durable_decorator.png)](https://codeclimate.com/github/jumph4x/durable_decorator)

This is a project for modifying the behavior of gems outside of your reach. You may be using a large Rails Engine and be wanting to simple decorate some existing behavior, but at the same time you want to inherit original behavior. 

## On tracking new decorators and managing fragility

After a lovely and short discussion with [Brian Quinn](https://github.com/BDQ) regarding these ideas, he mentioned we could try hashing methods to be able to raise warnings upon unexpected sources or targets (see his work on [Deface](https://github.com/spree/deface)). This project relies on another lovely meta-programming creation by [John Mair](https://github.com/banister), specifically his work on [method_source](https://github.com/banister/method_source).

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
  decorate :string_method do
    string_method_old + " and new"
  end
end

instance = ExampleClass.new
instance.string_method
# => "original and new"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
