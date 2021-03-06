require 'spec_helper'

describe Api::V1::LineItemsController, :type => :controller do

  before do
    @user = create(:user)
    sign_in @user
  end

  describe '#index' do
    describe 'unfiltered' do
      it 'returns all line_items' do
        FactoryGirl.create_list(:line_item, 5)

        get :index

        parsed_response = JSON.parse(response.body)
        expect(parsed_response.length).to eq(5)
        expect(parsed_response.first['user_id']).to_not be_nil
        expect(parsed_response.first['item_id']).to_not be_nil
      end
    end
  end

  describe '#create' do
    context 'valid attributes' do
      attrs = nil

      before do
        attrs = FactoryGirl.attributes_for(:line_item)
          .merge(item_id: create(:item).id)
      end

      it 'creates a new line_item' do
        expect{
          post :create, attrs
        }.to change(LineItem, :count).by(1)
      end

      it 'returns the new model' do
        post :create, attrs

        parsed_response = JSON.parse(response.body)
        expect(parsed_response["user_id"]).to eq(@user.id)
        expect(parsed_response["item_id"]).to eq(attrs[:item_id])
      end
    end

    context 'invalid attributes' do
      attrs = nil

      before do
        attrs = FactoryGirl.attributes_for(:line_item)
        attrs[:user_id] = nil
      end

      it 'does not create a new line_item' do
        expect{
          post :create, attrs
        }.to change(LineItem, :count).by(0)
      end

      it '422s' do
        post :create, attrs
        expect(response.status).to eq(422)
      end
    end
  end

  describe '#update' do
    before do
      @line_item = FactoryGirl.create(:line_item, user_id: @user.id, liked: true)
    end

    it 'updates the model' do
      put :update, id: @line_item.id, liked: false
      @line_item.reload
      expect(@line_item.liked).to be false
    end
  end

  describe '#destroy' do
    before do
      @line_item = FactoryGirl.create(:line_item, user_id: @user.id)
    end

    it 'destroys the model' do
      expect{
        delete :destroy, id: @line_item.id
      }.to change(LineItem, :count).by(-1)
    end

    it 'renders the model' do
      delete :destroy, id: @line_item.id

      parsed_response = JSON.parse(response.body)
      expect(parsed_response["user_id"]).to eq(@line_item.user_id)
      expect(parsed_response["item_id"]).to eq(@line_item.item_id)
    end
  end
end
