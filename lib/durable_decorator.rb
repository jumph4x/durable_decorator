# dependency for extracting method bodies and comments
require 'method_source'

# basic logging, trying to avoid pulling in rails
require 'logging'

# core
require "durable_decorator/version"
require "durable_decorator/constantizer"
require "durable_decorator/base"

# errors
require "durable_decorator/bad_arity_error"
require "durable_decorator/undefined_method_error"

module DurableDecorator
end

# monkey-patching Ruby core to create an API
Object.class_eval do
  class << self
    def decorate method_name, &block
      DurableDecorator::Base.redefine self, method_name, &block
    end

    def decorate_singleton method_name, &block
      decorate "self.#{method_name}", &block
    end
  end
end
