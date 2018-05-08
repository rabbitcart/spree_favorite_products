module Spree
  class Favorite < ActiveRecord::Base
    with_options required: true do
      belongs_to :favoritable, polymorphic: true, counter_cache: :favorite_users_count 
      belongs_to :user
    end

    validates :user_id, uniqueness: { scope: [:favoritable_id, :favoritable_type], message: Spree.t(:duplicate_favorite), allow_blank: true }

    # scope :with_product_id, ->(id) { joins(:product).readonly(false).merge(Spree::Product.where(id: id)) }
  end
end
