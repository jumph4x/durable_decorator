module DurableDecorator
  class Validator
    class << self
      DECORATION_MODES = ['strict']

      def validate_decoration_meta clazz, method_name, old_method, meta
        return unless meta

        chill_meta = Util.symbolized_hash(meta)

        raise InvalidDecorationError, "The hash provided to the decorator is invalid" unless DECORATION_MODES.include? chill_meta[:mode] and chill_meta[:sha] and !chill_meta[:sha].empty?
        raise TamperedDefinitionError, "Method SHA mismatch, the definition has been tampered with" unless Util.method_sha(old_method) == chill_meta[:sha]
      end

      def validate_method_arity clazz, method_name, old_method, &block
        raise BadArityError, "Attempting to override #{clazz}'s #{method_name} with incorrect arity." if block.arity != old_method.arity and block.arity > 0 # See the #arity behavior disparity between 1.8- and 1.9+
      end

      def validate_existing_definition clazz, method_name
        begin
          clazz.instance_method(method_name)
        rescue NameError => e
          raise UndefinedMethodError, "#{clazz}##{method_name} is not defined."
        end
      end
    end
  end
end

