require 'rspec'
require 'durable_decorator'

RSpec.configure do |config|
  config.before(:each) do
    require 'example_class'
  end
end
