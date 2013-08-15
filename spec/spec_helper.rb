require 'rspec'
require 'durable_decorator'
require 'rspec/logging_helper'

RSpec.configure do |config|
  include RSpec::LoggingHelper
  config.capture_log_messages

  config.before(:each) do
    load 'example_class.rb'
    load 'sample_module.rb'

    DurableDecorator::Base.reset!
    DurableDecorator::Util.stub(:logger).and_return(Logging.logger['SuperLogger'])
  end
end
