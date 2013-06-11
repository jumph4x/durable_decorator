require 'digest/sha1'

module DurableDecorator
  class Base
    class << self
      REDEFINITIONS = {}

      def redefine clazz, method_name, &block
        old_method = existing_method clazz, method_name, &block

        sha = method_sha(old_method)
  
        clazz.class_eval do
          alias_method("#{method_name}_#{sha}", method_name)
          alias_method("#{method_name}_old", method_name)

          define_method(method_name.to_sym, &block)
        end

        store_redefinition clazz, method_name, old_method, block

        true
      end

      # Ensure method exists before creating new definitions
      def existing_method clazz, method_name, &block
        return false if redefined? clazz, method_name, &block

        begin
          old_method = clazz.instance_method(method_name)
        rescue NameError => e
          raise UndefinedMethodError, "#{clazz}##{method_name} is not defined."
        end

        block_arity = safe_arity_check(&block)
        raise BadArityError, "Attempting to override #{clazz}'s #{method_name} with incorrect arity." if block_arity != old_method.arity # See the #arity behavior disparity between 1.8- and 1.9+

        old_method
      end

      def safe_arity_check &block
        # Necessary due to the different #arity handling on Procs by 1.9+ and 1.8-
        Dummy.define_method(:arity_check, &block)
        Dummy.instance_method(:arity_check).arity
      end

      def store_redefinition clazz, name, old_method, new_method
        class_index = REDEFINITIONS[clazz.name.to_sym] ||= {}
        method_index = class_index[name.to_sym] ||= []
       
        to_store = [new_method]
        to_store.unshift(old_method) if method_index.empty?
        
        to_store.each do |method|
          method_index << method_hash(name, method)
        end

        true
      end

      def method_hash name, method
        {
          :name => name,
          :sha => method_sha(method) 
        }
      end

      def method_sha method
        Digest::SHA1.hexdigest(method.source.gsub(/\s+/, ' '))
      end

      def redefined? clazz, method_name, &block
        begin
          overrides = REDEFINITIONS[clazz][method_name] and
          overrides.select{|o| o == method_hash(method_name)}.first and
          true
        rescue
          false
        end
      end
    end
  end
end
