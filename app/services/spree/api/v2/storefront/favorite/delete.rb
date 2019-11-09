module Spree::Api::V2::Storefront
  module Favorite
    class Delete
      prepend Spree::ServiceModule::Base

      def call(favorite:)
        ActiveRecord::Base.transaction do
          favorite.destroy!
        end
        success(favorite)
      end

    end
  end
end
