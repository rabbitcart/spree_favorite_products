module Spree::VariantDecorator
  def self.prepended(base)
    base.has_many :favorites, as: :favoritable, dependent: :destroy
    base.has_many :favorite_users, through: :favorites, class_name: Spree.user_class.name, source: :user, foreign_key: :user_id
    base.scope :favorite, -> { joins(:favorites).distinct }
    base.scope :order_by_favorite_users_count, ->(asc = false) { order(favorite_users_count: "#{asc ? 'asc' : 'desc'}") }
  end
end

Spree::Variant.prepend Spree::VariantDecorator
