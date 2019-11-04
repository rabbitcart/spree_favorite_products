module Spree::AppConfigurationDecorator
  def self.prepended(base)
    base.preference :favorite_products_per_page, :integer, default: 10
    base.preference :favorite_users_per_page, :integer, default: 10
  end
end

Spree::AppConfiguration.prepend Spree::AppConfigurationDecorator
