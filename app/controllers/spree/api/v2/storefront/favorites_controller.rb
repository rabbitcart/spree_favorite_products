module Spree
  module Api
    module V2
      module Storefront
        class FavoritesController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          def index
            require_spree_current_user
            render_serialized_payload { serialize_collection(paginated_collection) }
          end

          def show
            render_serialized_payload { serialize_resource(resource) }
          end

          def create
            require_spree_current_user

            favorite_params = {
              user: spree_current_user,
              favorite_params: {
                favoritable_type: params[:favoritable_type],
                favoritable_id: params[:favoritable_id]
              }
            }

            result = create_service.call(favorite_params)

            if result.success?
              render_serialized_payload(201) { serialize_resource(result.value) }
            else
              render_error_payload(result.error)
            end
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

          # THIS HAS BEEN MOVED TO BASE CONTROLLER
          def serialize_collection(collection)
            collection_serializer.new(
              collection,
              collection_options(collection)
            ).serializable_hash
          end
      
          # THIS HAS BEEN MOVED TO BASE CONTROLLER
          def collection_options(collection)
            {
              links: collection_links(collection),
              meta: collection_meta(collection),
              include: resource_includes,
              fields: sparse_fields
            }
          end

          def resource
            scope.find(params[:id])
          end

          def resource_serializer
            Spree::V2::Storefront::FavoriteSerializer
          end

          def collection_serializer
            Spree::V2::Storefront::FavoriteSerializer
          end

          def scope
            Spree::Favorite.accessible_by(current_ability, :show).includes(scope_includes)
          end

          def current_ability
            @current_ability ||= Spree::FavoriteAbility.new(spree_current_user)
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

          def paginated_collection
            collection_paginator.new(collection, params).call
          end

          def collection
            spree_current_user.favorites if spree_current_user
          end
  
          def collection_paginator
            Spree::Api::Dependencies.storefront_collection_paginator.constantize
          end

        end
      end
    end
  end
end
