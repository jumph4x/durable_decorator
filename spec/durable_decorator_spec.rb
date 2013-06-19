require 'spec_helper'

describe DurableDecorator::Base do

  context 'with classes' do
  # Spec uses ./example_class.rb
    context 'for existing instance methods' do
      it 'guarantees access to #method_original' do
        ExampleClass.class_eval do
          durably_decorate :no_param_method do
            no_param_method_original + " and a new string"
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
        it 'guarantees access to #method_original' do
          ExampleClass.class_eval do
            durably_decorate :one_param_method do |another_string|
              "#{one_param_method_original('check')} and #{another_string}"
            end
          end

          instance = ExampleClass.new
          instance.one_param_method("here we go").should == 'original: check and here we go'
        end
      end

      context 'for double decorations' do
        before do
          ExampleClass.class_eval do
            durably_decorate :one_param_method do |another_string|
              "#{one_param_method_1884eb7af7abbccec3fd4048f99363a3('check')} and #{another_string}"
            end
          end
        end

        it 'works with explicit method version invocation' do
          ExampleClass.class_eval do
            durably_decorate :one_param_method do |boolean|
              if boolean
                one_param_method_original("older")
              else
                one_param_method_4785("newer")
              end
            end
          end

          instance = ExampleClass.new
          instance.one_param_method(true).should == "original: older"
          instance.one_param_method(false).should == 'original: check and newer'
        end

        it 'work with short explicit method version invocation' do
          instance = ExampleClass.new
          instance.one_param_method_1884('').should == "original: "
          instance.one_param_method_1884eb('').should == "original: "
        end
      end

      context 'for strict definitions' do
        context 'with the correct SHA' do
          it 'guarantees access to #method_original' do
            ExampleClass.class_eval do
              meta = {
                :mode => 'strict',
                :sha => 'ba3114b2d46caa684b3f7ba38d6f74b2'
              }
              durably_decorate :no_param_method, meta do
                no_param_method_original + " and a new string"
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
                  no_param_method_original + " and a new string"
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
                  no_param_method_original + " and a new string"
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
      it 'guarantees access to ::method_original' do
        ExampleClass.class_eval do
          durably_decorate_singleton :clazz_level do
            clazz_level_original + " and a new string"
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
        it 'guarantees access to ::method_original' do
          ExampleClass.class_eval do
            durably_decorate_singleton :clazz_level_paramed do |another_string|
              "#{clazz_level_paramed_original('check')} and #{another_string}"
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
      it 'guarantees access to #method_original' do
        Sample.class_eval do
          durably_decorate :module_method do
            module_method_original + " and a new string"
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
            'ba3114b2d46caa684b3f7ba38d6f74b2'
        end
      end

      context 'when the target is a class method' do
        it 'should return the sha' do
          DurableDecorator::Base.determine_sha('ExampleClass.clazz_level').should ==
            'c5a3870a3934ce8d2145b841e42a8ad4'
        end
      end
    end
  end
end
