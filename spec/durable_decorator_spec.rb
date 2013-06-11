require 'spec_helper'

describe DurableDecorator do
  before do
    class ExampleClass
      def string_method
        "old string"
      end
    end
  end

  context 'for existing instance methods' do
    before do
      ExampleClass.class_eval do
        decorate :string_method do 
          string_method_old + " and a new string"
        end
      end
    end

    it 'guarantees access to #old' do
      instance = ExampleClass.new
      instance.string_method.should == 'old string and a new string'
    end 

    context 'with incorrect arity' do
      it 'throws an error' do
      lambda{
        ExampleClass.class_eval do
          decorate :string_method do |arg1, arg2|
            string_method_old + " and new string"
          end
        end
      }.should raise_error(DurableDecorator::BadArityError)
      end
    end
  end

  context 'for methods not yet defined' do
    it 'throws an error' do
      lambda{
        ExampleClass.class_eval do
          decorate :integer_method do 
            string_method_old + " and new string"
          end
        end
      }.should raise_error(DurableDecorator::UndefinedMethodError)
    end
  end
end
