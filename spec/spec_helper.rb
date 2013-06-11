require 'rspec'
require 'durable_decorator'

RSpec.configure do |config|
  config.before(:each) do
    load 'example_class.rb'
  end
end
