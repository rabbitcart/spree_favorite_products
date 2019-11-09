require 'factory_bot'

Spree::Zone.class_eval do
  def self.global
    find_by(name: 'GlobalZone') || FactoryBot.create(:global_zone)
  end
end

gem_dir = Gem::Specification.find_by_name("spree_core").gem_dir
Dir["#{gem_dir}/lib/spree/testing_support/factories/**/*.rb"].each { |f| require f }

FactoryBot.define do
  sequence(:random_string) { FFaker::Lorem.sentence }
  sequence(:random_description) { FFaker::Lorem.paragraphs(Kernel.rand(1..5)).join("\n") }
  sequence(:random_email) { FFaker::Internet.email }

  sequence(:sku) { |n| "SKU-#{n}" }
end

FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
