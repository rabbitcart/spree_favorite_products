require 'spec_helper'

describe 'Storefront API v2 Account spec', type: :request do
  # include_context 'API v2 tokens'

  before(:each) do
    @user = Spree.user_class.create! email: 'test@example.com', password: 'spree123'
    @token = Doorkeeper::AccessToken.create!(resource_owner_id: @user.id, expires_in: nil)
    @headers_bearer = { 'Authorization' => "Bearer #{@token.token}" }

    @admin = Spree.user_class.create! email: 'admin@example.com', password: 'spree123'
    @admin.spree_roles << Spree::Role.find_or_create_by(name: "admin")
    @admin_token = Doorkeeper::AccessToken.create!(resource_owner_id: @admin.id, expires_in: nil)
    @admin_headers_bearer = { 'Authorization' => "Bearer #{@admin_token.token}" }

    shipping_category = Spree::ShippingCategory.create! name: 'shipping_category'
    @product1 = Spree::Product.create! name: 'product1', price: 100, shipping_category_id: shipping_category.id
    favorite = Spree::Favorite.new
    favorite.favoritable_id = @product1.id
    favorite.favoritable_type = 'Spree::Product'
    favorite.user_id = @user.id
    favorite.save!
  end

  let(:headers) { @headers_bearer }
  describe 'account#show' do
    before { get '/api/v2/storefront/account', headers: headers }

    it_behaves_like 'returns 200 HTTP status'

    context 'with params "include=favourites"' do
      before { get '/api/v2/storefront/account?include=favorites', headers: headers }

      it 'returns account data with included favorite' do
        expect(json_response['included']).to    include(have_type('favorite'))
        expect(json_response['included'][0]).to eq(Spree::V2::Storefront::FavoriteSerializer.new(@user.favorites.first).as_json['data'])
      end
    end

    context 'as a guest user' do
      let(:headers) { {} }
      before { get '/api/v2/storefront/account?include=favorites', headers: headers }

      it_behaves_like 'returns 403 HTTP status'
    end

    context 'as an admin user' do
      let(:headers) { @admin_headers_bearer }
      before { get '/api/v2/storefront/account?include=favorites', headers: headers }

      it_behaves_like 'returns 200 HTTP status'

    end
  end
end
