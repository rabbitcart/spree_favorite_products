require 'spec_helper'

describe 'Storefront API v2 Favorite spec', type: :request do
  # include_context 'API v2 tokens'

  before(:each) do
    @user = Spree.user_class.create! email: 'test@example.com', password: 'spree123'
    @admin = Spree.user_class.create! email: 'admin@example.com', password: 'spree123'
    @admin.spree_roles << Spree::Role.find_or_create_by(name: "admin")
    @token = Doorkeeper::AccessToken.create!(resource_owner_id: @user.id, expires_in: nil)
    @admin_token = Doorkeeper::AccessToken.create!(resource_owner_id: @admin.id, expires_in: nil)
    @headers_bearer = { 'Authorization' => "Bearer #{@token.token}" }
    @admin_headers_bearer = { 'Authorization' => "Bearer #{@admin_token.token}" }
    shipping_category = Spree::ShippingCategory.create! name: 'shipping_category'
    @product1 = Spree::Product.create! name: 'product1', price: 100, shipping_category_id: shipping_category.id
    @product2 = Spree::Product.create! name: 'product2', price: 50, shipping_category_id: shipping_category.id
    @product3 = Spree::Product.create! name: 'product3', price: 50, shipping_category_id: shipping_category.id
    @favorite = Spree::Favorite.new
    @favorite.favoritable_id = @product1.id
    @favorite.favoritable_type = 'Spree::Product'
    @favorite.user_id = @user.id
    @favorite.save!
    @favorite2 = Spree::Favorite.new
    @favorite2.favoritable_id = @product3.id
    @favorite2.favoritable_type = 'Spree::Product'
    @favorite2.user_id = @user.id
    @favorite2.save!
  end

  let(:headers) { @headers_bearer }
  describe 'favorite#show' do
    before { get "/api/v2/storefront/favorites/#{@favorite.id}", headers: headers }

    it_behaves_like 'returns 200 HTTP status'

    context 'with params "include=favoritable"' do
      before { get "/api/v2/storefront/favorites/#{@favorite.id}?include=favoritable", headers: headers }

      it 'returns favorite data with included favorite' do
        # pp json_response
        expect(json_response['included']).to    include(have_type('product'))
        expect(json_response['included'][0]).to eq(Spree::V2::Storefront::ProductSerializer.new(@product1).as_json['data'])
      end
    end

    context 'as a guest user' do
      let(:headers) { {} }
      before { get "/api/v2/storefront/favorites/#{@favorite.id}", headers: headers }

      it_behaves_like 'returns 404 HTTP status'
    end

    context 'favorite does not exist' do
      before { get "/api/v2/storefront/favorites/5", headers: headers }
      it_behaves_like 'returns 404 HTTP status'
    end

    context 'as an admin user' do
      let(:headers) { @admin_headers_bearer }
  
      before { get "/api/v2/storefront/favorites/#{@favorite.id}", headers: headers }

      it_behaves_like 'returns 200 HTTP status'
    end

  end

  describe 'favorite#create' do
    let(:params) { { favoritable_type: "Spree::Product", favoritable_id: @product2.id } }
    before { post "/api/v2/storefront/favorites", params: params, headers: headers }

    it_behaves_like 'returns 201 HTTP status'

    it 'returns favorite data' do
      expect(json_response['data']['attributes']['favoritable_id']).to eq(@product2.id)
      expect(json_response['data']['attributes']['favoritable_type']).to eq("Spree::Product")
      expect(json_response['data']['attributes']['user_id']).to eq(@user.id)
    end

    context 'as a guest user' do
      let(:headers) { {} }
      before { post "/api/v2/storefront/favorites", params: params, headers: headers }

      it_behaves_like 'returns 403 HTTP status'
    end

  end

  describe 'favorite#delete' do
    before { delete "/api/v2/storefront/favorites/#{@favorite.id}", headers: headers }

    it_behaves_like 'returns 200 HTTP status'

    it 'returns favorite data' do
      expect(json_response['data']['attributes']['favoritable_id']).to eq(@product1.id)
      expect(json_response['data']['attributes']['favoritable_type']).to eq("Spree::Product")
      expect(json_response['data']['attributes']['user_id']).to eq(@user.id)
    end

    context 'as another user' do
      user2 = Spree.user_class.create! email: 'test2@example.com', password: 'spree123'
      token2 = Doorkeeper::AccessToken.create!(resource_owner_id: user2.id, expires_in: nil)
      headers_bearer2 = { 'Authorization' => "Bearer #{token2.token}" }
      let(:headers) { headers_bearer2 }
  
      before { delete "/api/v2/storefront/favorites/#{@favorite.id}", headers: headers }

      it_behaves_like 'returns 403 HTTP status'
    end

    context 'as a guest user' do
      let(:headers) { {} }
      before { delete "/api/v2/storefront/favorites/#{@favorite.id}", headers: headers }

      it_behaves_like 'returns 403 HTTP status'
    end

    context 'favorite does not exist' do
      before { delete "/api/v2/storefront/favorites/5", headers: headers }
      it_behaves_like 'returns 404 HTTP status'
    end

    context 'as an admin user' do
      let(:headers) { @admin_headers_bearer }
  
      before { delete "/api/v2/storefront/favorites/#{@favorite2.id}", headers: headers }

      it_behaves_like 'returns 200 HTTP status'
    end

  end
end
