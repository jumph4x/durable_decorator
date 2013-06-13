require 'spec_helper'

describe 'Ruby' do
  it 'correctly identifies the method #source_location' do
    DurableDecorator::Base.method(:existing_method).source_location.join.should match(/durable_decorator\/base\.rb/)
  end

  it 'makes an attempt at extracting the method body' do
    DurableDecorator::Base.method(:existing_method).source.should match /old_method/
  end

  it 'makes an attempt at extracting the method comment' do
    DurableDecorator::Base.method(:existing_method).comment.should match /ensure method exists/i
  end
end
