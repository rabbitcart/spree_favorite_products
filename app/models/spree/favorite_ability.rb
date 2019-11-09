module Spree
  class FavoriteAbility
    include CanCan::Ability

    def initialize(user)
      alias_action :show, to: :read

      user ||= Spree.user_class.new
      if user.respond_to?(:has_spree_role?) && user.has_spree_role?('admin')
        can :manage, Spree::Favorite
      else
        can :read,
        Spree::Favorite,
            :user_id => user.id
        can :create,
        Spree::Favorite,
            user.present? && :user_id => user.id
        can :delete, Spree::Favorite do |favorite, user|
          favorite.user_id == user.id
        end
      end
    end
  end
end
