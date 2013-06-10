module DurableDecorator
  class Base
    class << self
      REDEFINITIONS = {}

      def redefine clazz, method_name, &block
        begin
          old_method = clazz.instance_method(method_name)
        rescue NameError => e
          raise UndefinedMethodError, "#{clazz}##{method_name} is not defined."
        end

        raise BadArityError, "Attempting to override #{clazz}##{method_name} with incorrect arity." unless block.arity == old_method.arity
        #store_redefinition(clazz, method_name, old_method)

        clazz.class_eval do
          instance_variable_set(previous_method_name(method_name, true), instance_method(method_name))
        end
      end

      def previous_method_name name, inst_var = false
        base = "old_#{name}_method"
        base = "@#{base}" if inst_var
        base.to_sym
      end
     # def store_redefinition clazz, name, old_method
     #   class_index = REDEFINITIONS[clazz.to_sym] ||= {}
     #   method_index = class_index[methud.to_sym] ||= []
     #   method_index << {
     #     :source => old_method.source,
     #     :name => name,
     #     :hash => 
     #   }
     # end
    end
  end
end
