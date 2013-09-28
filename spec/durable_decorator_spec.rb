require 'spec_helper'

describe DurableDecorator::Base do

  context 'with classes' do
  # Spec uses ./example_class.rb
    context 'for existing instance methods' do
      it 'guarantees access to #original_method' do
        ExampleClass.class_eval do
          durably_decorate :no_param_method do
            original_no_param_method + " and a new string"
          end
        end

        instance = ExampleClass.new
        instance.no_param_method.should == 'original and a new string'
      end

      context 'with incorrect arity' do
        it 'throws an error' do
          lambda{
            ExampleClass.class_eval do
              durably_decorate(:no_param_method){|a,b| }
            end
          }.should raise_error(DurableDecorator::BadArityError)
        end
      end

      context 'for methods with parameters' do
        it 'guarantees access to #original_method' do
          ExampleClass.class_eval do
            durably_decorate :one_param_method do |another_string|
              "#{original_one_param_method('check')} and #{another_string}"
            end
          end

          instance = ExampleClass.new
          instance.one_param_method("here we go").should == 'original: check and here we go'
        end
      end

      context 'for re-run decorations' do
        it 'does not create a new redefinition' do
          2.times {
            ExampleClass.class_eval do
              durably_decorate :no_param_method do
                original_no_param_method + " and a new string"
              end
            end
          }
          DurableDecorator::Base.definitions['ExampleClass#no_param_method'].size.should == 2 # original definition and one deoration
        end
      end

      context 'for double decorations' do
        before do
          ExampleClass.class_eval do
            durably_decorate :one_param_method do |another_string|
              "#{_935888f04d9e132be458591d5755cb8131fec457_one_param_method('check')} and #{another_string}"
            end
          end
        end

        it 'works with explicit method version invocation' do
          ExampleClass.class_eval do
            durably_decorate :one_param_method do |boolean|
              if boolean
                original_one_param_method("older")
              else
                _b844_one_param_method("newer")
              end
            end
          end

          instance = ExampleClass.new
          instance.one_param_method(true).should == "original: older"
          instance.one_param_method(false).should == 'original: check and newer'
        end

        it 'work with short explicit method version invocation' do
          instance = ExampleClass.new
          instance._9358_one_param_method('').should == "original: "
          instance._935888_one_param_method('').should == "original: "
        end

        it 'maintains history of decorations' do
          DurableDecorator::Base.definitions['ExampleClass#one_param_method'].size.should == 2
        end
      end

      context 'for strict definitions' do
        context 'with the correct SHA' do
          it 'guarantees access to #method_original' do
            ExampleClass.class_eval do
              meta = {
                :mode => 'strict',
                :sha => 'd54f9c7ea2038fac0ae2ff9af49c56f35761725d'
              }
              durably_decorate :no_param_method, meta do
                original_no_param_method + " and a new string"
              end
            end

            instance = ExampleClass.new
            instance.no_param_method.should == "original and a new string"
          end
        end

        context 'with the wrong SHA' do
          it 'raises an error' do
            lambda{
              ExampleClass.class_eval do
                meta = {
                  :mode => 'strict',
                  :sha => '1234wrong'
                }
                durably_decorate :no_param_method, meta do
                  original_no_param_method + " and a new string"
                end
              end
            }.should raise_error(DurableDecorator::TamperedDefinitionError)
          end
        end

        context 'for an invalid config' do
          it 'raises an error' do
            lambda{
              ExampleClass.class_eval do
                meta = {
                  :mode => 'strict'
                }
                durably_decorate :no_param_method, meta do
                  original_no_param_method + " and a new string"
                end
              end
            }.should raise_error(DurableDecorator::InvalidDecorationError)
          end
        end
      end

      context 'for soft definitions' do
        context 'with the correct SHA' do
          it 'guarantees access to #original_method' do
            ExampleClass.class_eval do
              meta = {
                :mode => 'soft',
                :sha => 'd54f9c7ea2038fac0ae2ff9af49c56f35761725d'
              }
              durably_decorate :no_param_method, meta do
                original_no_param_method + " and a new string"
              end
            end

            instance = ExampleClass.new
            instance.no_param_method.should == "original and a new string"
          end
        end

        context 'with the wrong SHA' do
          it 'logs a warning but does not raise an error' do
            ExampleClass.class_eval do
              meta = {
                :mode => 'soft',
                :sha => '1234wrong'
              }
              durably_decorate :no_param_method, meta do
                original_no_param_method + " and a new string"
              end
            end
            @log_output.readline.should match(/invalid SHA/)
          end
        end

        context 'when lacking SHA' do
          it 'prints the SHA suggestion' do
            ExampleClass.class_eval do
              durably_decorate :no_param_method do
                no_param_method_original + " and a new string"
              end
            end
            @log_output.readline.should match(/d54f9c7ea2038fac0ae2ff9af49c56f35761725d/)
          end
        end

        context 'for an invalid config' do
          it 'raises an error' do
            lambda{
              ExampleClass.class_eval do
                meta = {
                  :mode => 'strict'
                }
                durably_decorate :no_param_method, meta do
                  original_no_param_method + " and a new string"
                end
              end
            }.should raise_error(DurableDecorator::InvalidDecorationError)
          end
        end
      end
    end

    context 'for methods not yet defined' do
      it 'throws an error' do
        lambda{
          ExampleClass.class_eval do
            durably_decorate(:integer_method){ }
          end
        }.should raise_error(DurableDecorator::UndefinedMethodError)
      end
    end

    context 'for existing class methods' do
      it 'guarantees access to ::original_method' do
        ExampleClass.class_eval do
          durably_decorate_singleton :clazz_level do
            original_clazz_level + " and a new string"
          end
        end

        ExampleClass.clazz_level.should == 'original and a new string'
      end

      context 'with incorrect arity' do
        it 'throws an error' do
          lambda{
            ExampleClass.class_eval do
              durably_decorate_singleton(:clazz_level){|a,b| }
            end
          }.should raise_error(DurableDecorator::BadArityError)
        end
      end

      context 'for methods with parameters' do
        it 'guarantees access to ::original_method' do
          ExampleClass.class_eval do
            durably_decorate_singleton :clazz_level_paramed do |another_string|
              "#{original_clazz_level_paramed('check')} and #{another_string}"
            end
          end

          ExampleClass.clazz_level_paramed("here we go").should == 'original: check and here we go'
        end
      end
    end

    context 'for methods not yet defined' do
      it 'throws an error' do
        lambda{
          ExampleClass.class_eval do
            durably_decorate_singleton(:integer_method){ }
          end
        }.should raise_error(DurableDecorator::UndefinedMethodError)
      end
    end
  end

  context 'with modules' do
  # Spec uses ./sample_module.rb
    context 'for existing methods' do
      it 'guarantees access to #original_method' do
        Sample.class_eval do
          durably_decorate :module_method do
            original_module_method + " and a new string"
          end
        end

        o = Object.new
        o.extend(Sample)
        o.module_method.should == 'original and a new string'
      end

      context 'with incorrect arity' do
        it 'throws an error' do
          lambda{
            Sample.class_eval do
              durably_decorate(:module_method){|a,b| }
            end
          }.should raise_error(DurableDecorator::BadArityError)
        end
      end
    end

    context 'for methods not yet defined' do
      it 'throws an error' do
        lambda{
          Sample.class_eval do
            durably_decorate(:integer_method){ }
          end
        }.should raise_error(DurableDecorator::UndefinedMethodError)
      end
    end
  end

  context 'finding the sha' do
    context 'when asked to find the sha' do
      context 'when the target is invalid' do
        it 'should raise an error' do
          lambda{
            DurableDecorator::Base.determine_sha 'invalid'
          }.should raise_error
        end
      end

      context 'when the target is an instance method' do
        it 'should return the sha' do
          DurableDecorator::Base.determine_sha('ExampleClass#no_param_method').should ==
            'd54f9c7ea2038fac0ae2ff9af49c56f35761725d'
        end
      end

      context 'when the target is a class method' do
        it 'should return the sha' do
          DurableDecorator::Base.determine_sha('ExampleClass.clazz_level').should ==
            'f6490bec1af021697ed8e5990f0d1db3976f065f'
        end
      end
    end
  end
end
