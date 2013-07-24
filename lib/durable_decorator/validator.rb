module DurableDecorator
  class Validator
    class << self
      DECORATION_MODES = ['strict', 'soft']

      def validate_decoration_meta clazz, method_name, old_method, meta
        return unless meta

        chill_meta = Util.symbolized_hash(meta)

        raise InvalidDecorationError, "The hash provided to the decorator is invalid" unless DECORATION_MODES.include? chill_meta[:mode] and chill_meta[:sha] and !chill_meta[:sha].empty?
        send("handle_#{chill_meta[:mode]}_fault", clazz, method_name) unless Util.method_sha(old_method) == chill_meta[:sha]
      end

      def handle_strict_fault(*args)
        raise TamperedDefinitionError, "Method SHA mismatch, the definition has been tampered with"
      end

      def handle_soft_fault(clazz, method_name)
        Util.logger.fatal "#{clazz}##{method_name} decoration uses an invalid SHA. The original method definition could have been tampered with!"
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

