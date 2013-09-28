require 'digest/sha1'

module DurableDecorator
  class Base
    class << self
      DEFINITIONS = {}

      def reset!
        DEFINITIONS.clear
      end

      def redefine clazz, method_name, meta, &block
        if method_name.to_s.match /^self\./
          redefine_instance (class << clazz; self; end), method_name.to_s.gsub("self.",''), meta, &block
        else
          redefine_instance clazz, method_name, meta, &block
        end
      end

      def redefine_instance clazz, method_name, meta, &block
        return unless old_method = existing_method(clazz, method_name, meta, &block)

        alias_original clazz, method_name
        alias_definitions clazz, method_name, Util.method_sha(old_method)
        redefine_method clazz, method_name, &block

        store_redefinition clazz, method_name, old_method, block
      end

      # Ensure method exists before creating new definitions
      def existing_method clazz, method_name, meta, &block
        return if redefined?(clazz, method_name, &block)

        old_method = Validator.validate_existing_definition clazz, method_name
        Validator.validate_method_arity clazz, method_name, old_method, &block
        Validator.validate_decoration_meta clazz, method_name, old_method, meta

        old_method
      end


      def redefine_method clazz, method_name, &block
        clazz.class_eval do
          define_method(method_name.to_sym, &block)
        end
      end

      def definitions
        DEFINITIONS
      end

      def alias_definitions clazz, method_name, old_sha
        clazz.class_eval do
          alias_method("_#{old_sha}_#{method_name}", method_name)
          alias_method("_#{old_sha[0..3]}_#{method_name}", method_name)
          alias_method("_#{old_sha[0..5]}_#{method_name}", method_name)
        end
      end

      def alias_original clazz, method_name
        return unless original_redefinition? clazz, method_name

        clazz.class_eval do
          alias_method("original_#{method_name}", method_name)
        end
      end


      def original_redefinition? clazz, method_name
        defs = DEFINITIONS[Util.full_method_name(clazz, method_name)]
        !defs || defs.empty?
      end

      def store_redefinition clazz, name, old_method, new_method
        methods = (DEFINITIONS[Util.full_method_name(clazz, name)] ||= [])
       
        to_store = [new_method]
        to_store.unshift(old_method) if original_redefinition?(clazz, name)
        
        to_store.each do |method|
          methods << Util.method_hash(name, method)
        end

        true
      end

      def redefined? clazz, method_name, &block
        full_name = Util.full_method_name(clazz, method_name)
        redefs = DEFINITIONS[full_name] and
        redefs.include? Util.method_hash(method_name, block)
      end

      def determine_sha target
        Util.method_sha extract_method(target)
      end

      def determine_arity target
        extract_method(target).arity
      end

      def extract_method target
        raise "Please provide a fully qualified method name: Module::Clazz#instance_method or .clazz_method" unless target && target.match(/\.|#/)

        class_name, separator, method_name = target.match(/(.*)(\.|#)(.*)/)[1..3]
        clazz = Constantizer.constantize(class_name)
        method = if separator == '#'
          clazz.instance_method(method_name)
        else
          clazz.method(method_name)
        end
      end
    end
  end
end
