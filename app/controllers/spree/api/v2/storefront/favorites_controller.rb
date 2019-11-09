module Spree
  module Api
    module V2
      module Storefront
        class FavoritesController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          def show
            render_serialized_payload { serialize_resource(resource) }
          end

          def create
            require_spree_current_user
            # spree_authorize! :create, Spree::Favorite, spree_current_user

            # {"favoritable_type"=>"Spree::Product", "favoritable_id"=>1, "user_id"=>1}
            favorite_params = {
              user: spree_current_user,
              favorite_params: {
                favoritable_type: params[:favoritable_type],
                favoritable_id: params[:favoritable_id]
              }
            }

            favorite = create_service.call(favorite_params).value
            render_serialized_payload(201) { serialize_resource(favorite) }
          end

          def destroy
            require_spree_current_user
            spree_authorize! :delete, resource, spree_current_user
            favorite = resource
            delete_service.call(favorite: favorite)

            render_serialized_payload { serialize_resource(favorite) }
          end

          private
          # THIS HAS BEEN MOVED TO BASE CONTROLLER
          def serialize_resource(resource)
            resource_serializer.new(
              resource,
              include: resource_includes,
              fields: sparse_fields
            ).serializable_hash
          end

          def resource
            scope.find(params[:id])
          end

          def resource_serializer
            Spree::V2::Storefront::FavoriteSerializer
          end

          def scope
            Spree::Favorite.accessible_by(current_ability, :show).includes(scope_includes)
          end

          def current_ability
            @current_ability ||= Spree::Dependencies.ability_class.constantize.new(spree_current_user)
          end

          def scope_includes
            {
              favoritable: {}
            }
          end

          def create_service
            Spree::Api::V2::Storefront::Favorite::Create
          end

          def delete_service
            Spree::Api::V2::Storefront::Favorite::Delete
          end

        end
      end
    end
  end
end
