module Spree
  module V2
    module Storefront
      class FavoriteSerializer < BaseSerializer
        set_type   :favorite

        attributes :favoritable_type, :favoritable_id, :user_id
        belongs_to :favoritable, polymorphic: true
      end
    end
  end
end
