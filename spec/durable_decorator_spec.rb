require 'spec_helper'

describe DurableDecorator do
  
  # Spec uses example.rb class

  context 'for existing instance methods' do
    it 'guarantees access to #method_old' do
      ExampleClass.class_eval do
        decorate :no_param_method do 
          no_param_method_old + " and a new string"
        end
      end

      instance = ExampleClass.new
      instance.no_param_method.should == 'original and a new string'
    end 

    context 'with incorrect arity' do
      it 'throws an error' do
        lambda{
          ExampleClass.class_eval do
            decorate(:no_param_method){|a,b| }
          end
        }.should raise_error(DurableDecorator::BadArityError)
      end
    end

    context 'for methods with multiple parameters' do
      it 'guarantees access to #method_old' do
        ExampleClass.class_eval do
          decorate :one_param_method do |another_string|
            "#{one_param_method_old('check')} and #{another_string}"
          end
        end

        instance = ExampleClass.new
        instance.one_param_method("here we go").should == 'original: check and here we go'
      end
    end
  end

  context 'for methods not yet defined' do
    it 'throws an error' do
      lambda{
        ExampleClass.class_eval do
          decorate(:integer_method){ }
        end
      }.should raise_error(DurableDecorator::UndefinedMethodError)
    end
  end

  context 'when asked to find the sha' do
    context 'when the target is invalid' do
      it 'should raise an error' do
        lambda{ DurableDecorator::Base.determine_sha 'invalid' }.should raise_error
      end
    end

    context 'when the target is an instance method' do
      before{ require 'example_class' }
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
