require 'rails_helper'
describe API::V1::RecipesController do

  let(:user) { create :user, name: 'user' }

  describe "signed in" do
    before do
      sign_in user
    end

    describe 'create' do
      context 'success' do
        it "creates and serializes a recipe" do
          post :create, params: { url: 'http://stubbedurl.com/recipe.html'}
          expect(response.status).to eq 200
          # expect a serialized recipe, which has discussions and polls
        end
      end
    end

    describe 'show' do
      context 'success' do
        it "serializes a recipe" do
        	recipe = Recipe.create(title:, body:, url:) 
          get :show, params: { id: recipe.id }
          expect(response.status).to eq 200
          # expect a serialized recipe, which has discussions and polls
        end
      end
    end
  end

  describe "not signed in" do
  	# demonstrate access deined
  end
end
