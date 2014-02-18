module Namespace
  class ExampleClass
    def no_param_method
      "original"
    end

    def one_param_method param
      "original: #{param}"
    end

    def self.clazz_level
      "original"
    end

    def self.clazz_level_paramed param
      "original: #{param}"
    end

    private
    def private_method
      'private method'
    end

    protected
    def protected_method
      'protected method'
    end
  end
end
