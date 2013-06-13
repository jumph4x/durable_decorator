require 'digest/md5'

module DurableDecorator
  class Base
    class << self
      REDEFINITIONS = {}

      def redefine_singleton clazz, method_name, &block
        singleton_class = (class << clazz; self; end)
        redefine singleton_class, method_name, &block
      end

      def redefine clazz, method_name, &block
        return unless (old_method = existing_method clazz, method_name, &block)

        sha = method_sha(old_method)
  
        alias_definitions clazz, method_name, sha
        redefine_method clazz, method_name, &block

        store_redefinition clazz, method_name, old_method, block
      end

      # Ensure method exists before creating new definitions
      def existing_method clazz, method_name, &block
        return false if redefined? clazz, method_name, &block

        begin
          old_method = clazz.instance_method(method_name)
        rescue NameError => e
          raise UndefinedMethodError, "#{clazz}##{method_name} is not defined."
        end

        raise BadArityError, "Attempting to override #{clazz}'s #{method_name} with incorrect arity." if block.arity != old_method.arity and block.arity > 0 # See the #arity behavior disparity between 1.8- and 1.9+

        old_method
      end

      def redefine_method clazz, method_name, &block
        clazz.class_eval do
          define_method(method_name.to_sym, &block)
        end
      end

      def alias_definitions clazz, method_name, old_sha
        clazz.class_eval do
          alias_method("#{method_name}_#{old_sha}", method_name)
          alias_method("#{method_name}_old", method_name)
        end
      end

      def store_redefinition clazz, name, old_method, new_method
        class_name = (clazz.name || "Meta#{clazz.superclass.to_s}").to_sym
        class_index = REDEFINITIONS[class_name] ||= {}
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
        Digest::MD5.hexdigest(method.source.gsub(/\s+/, ' '))
      end

      def redefined? clazz, method_name, &block
        begin
          result =
            overrides = REDEFINITIONS[clazz][method_name] and
            overrides.select{|o| o == method_hash(method_name)}.first and
            true
        rescue
          false
        end
      end

      def logger
        return @logger if @logger

        @logger = Logging.logger(STDOUT)
        @logger.level = :warn
        @logger
      end

      def determine_sha target
        raise "Please provide a fully qualified method name: Module::Clazz#instance_method or ::clazz_method" unless target.match(/\.|#/)

        class_name, separator, method_name = target.match(/(.*)(\.|#)(.*)/)[1..3]
        clazz = Constantizer.constantize(class_name)
        method = if separator == '#'
          clazz.instance_method(method_name)
        else
          clazz.method(method_name)
        end

        method_sha(method)
      end
    end
  end
end
