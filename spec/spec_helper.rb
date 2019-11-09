# Run Coverage report
require 'simplecov'
require 'minitest/autorun'

require 'jsonapi/rspec'
require 'factory_bot'

SimpleCov.start 'rails'

ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'database_cleaner'
require 'ffaker'
require 'shoulda-matchers'
require 'rspec-activemodel-mocks'
require 'rails-controller-testing'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/preferences'
require 'devise'

gem_dir = Gem::Specification.find_by_name("spree_api").gem_dir
Dir["#{gem_dir}/spec/support/**/*.rb"].each do |f|
  require f
end

Dir["#{gem_dir}/lib/spree/api/testing_support/**/*.rb"].each do |f|
  require f
end

# Requires factories defined in lib/spree_favorite_products/factories.rb
# require 'spree_favorite_products/factories'
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include Spree::Core::Engine.routes.url_helpers
  config.include Rails::Controller::Testing::TestProcess, type: :controller
  config.include Rails::Controller::Testing::Integration, type: :controller
  config.include Rails::Controller::Testing::TemplateAssertions, type: :controller
  # config.include Devise::Test::ControllerHelpers, type: :controller
  config.include JSONAPI::RSpec
  config.include Spree::Api::TestingSupport::Helpers, type: :controller
  config.include Spree::Api::TestingSupport::Helpers, type: :request
  config.extend Spree::Api::TestingSupport::Setup, type: :controller

  config.mock_with :rspec
  config.color = true

  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.expose_current_running_example_as :example

  config.fail_fast = ENV['FAIL_FAST'] || false
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
    with.library :active_model
    with.library :action_controller
  end
end
