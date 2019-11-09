module Spree
  class FavoriteAbility
    include CanCan::Ability

    def initialize(user)
      alias_action :show, to: :read

      user ||= Spree.user_class.new
      if user.respond_to?(:has_spree_role?) && user.has_spree_role?('admin')
        can :manage, Favorite
      else
        can :read,
          Favorite,
            :user_id => user.id
        can :create,
          Favorite,
            user.present? && :user_id => user.id
        can :delete, Favorite do |favorite, user|
          favorite.user_id == user.id
        end
      end
    end
  end
end
