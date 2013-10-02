module DurableDecorator
  class Validator
    class << self
      DECORATION_MODES = ['strict', 'soft']

      def validate_decoration_meta clazz, method_name, old_method, meta
        expected_sha = Util.method_sha(old_method)
        
        unless meta
          log_sha_suggestion clazz, method_name, expected_sha
          return
        end

        chill_meta = Util.symbolized_hash(meta)
        provided_mode = chill_meta[:mode]
        provided_sha = chill_meta[:sha]

        raise InvalidDecorationError, "The :mode provided is invalid. Possible modes are: #{DECORATION_MODES.join(", ")}" unless DECORATION_MODES.include? provided_mode
        if provided_mode == 'strict'
          raise InvalidDecorationError, "The SHA provided appears to be empty" unless provided_sha and !provided_sha.empty?
        end
        send("handle_#{chill_meta[:mode]}_fault", clazz, method_name, expected_sha, provided_sha) unless expected_sha == provided_sha
      end

      def log_sha_suggestion clazz, method_name, expected_sha
        Util.logger.warn "#{clazz}##{method_name} definition's SHA is currently: #{expected_sha}. Consider sealing it against tampering."
      end

      def handle_strict_fault clazz, method_name, expected_sha, provided_sha
        raise TamperedDefinitionError, "Method SHA mismatch, the definition has been tampered with. #{expected_sha} is expected but #{provided_sha} was provided."
      end

      def handle_soft_fault clazz, method_name, expected_sha, provided_sha
        Util.logger.warn "#{clazz}##{method_name} decoration uses an invalid SHA. The original method definition could have been tampered with!"
        Util.logger.warn "Expected SHA was #{expected_sha} but the provided SHA is #{provided_sha}"
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

