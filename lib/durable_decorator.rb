require "durable_decorator/version"
require "durable_decorator/base"

# errors
require "durable_decorator/bad_arity_error"
require "durable_decorator/undefined_method_error"

module DurableDecorator
end

Object.class_eval do
  class << self
    def decorate method_name, &block
      DurableDecorator::Base.redefine self, method_name, &block
    end
  end
end
