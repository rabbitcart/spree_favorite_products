module Spree::V2::Storefront::UserSerializerDecorator
  def self.prepended(base)
    base.has_many :favorites, polymorphic: true
  end
end

Spree::V2::Storefront::UserSerializer.prepend Spree::V2::Storefront::UserSerializerDecorator
