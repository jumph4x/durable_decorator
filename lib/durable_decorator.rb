# dependency for extracting method bodies and comments
require 'method_source'

# basic logging, trying to avoid pulling in rails
require 'logging'

# core
require "durable_decorator/version"
require "durable_decorator/constantizer"
require "durable_decorator/base"
require "durable_decorator/util"
require "durable_decorator/validator"

# errors
require "durable_decorator/bad_arity_error"
require "durable_decorator/undefined_method_error"
require "durable_decorator/invalid_decoration_error"
require "durable_decorator/tampered_definition_error"

module DurableDecorator
end

# monkey-patching Ruby core to create an API
Object.class_eval do
  class << self
    def durably_decorate method_name, meta = nil, &block
      DurableDecorator::Base.redefine self, method_name, meta, &block
    end

    def durably_decorate_singleton method_name, meta = nil, &block
      durably_decorate "self.#{method_name}", meta, &block
    end
  end
end

Module.class_eval do
  def durably_decorate method_name, meta = nil, &block
    DurableDecorator::Base.redefine self, method_name, meta, &block
  end
end
