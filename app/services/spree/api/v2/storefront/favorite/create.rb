module Spree
  module Api
    module V2
      module Storefront
        module Favorite
          class Create
            prepend Spree::ServiceModule::Base

            def call(user:, favorite_params:)
              favorite_params[:user_id] = user.id

              favorite = Spree::Favorite.create!(favorite_params)
              success(favorite)
            end
          end
        end
      end
    end
  end
end
