require 'rails_helper'

describe ManifestController do
  describe 'show' do
    it 'responds with a manifest.json' do
      get :show, format: :json
      json = JSON.parse(response.body)
      expect(json['name']).to eq 'Loomio'
      expect(json['display']).to eq 'standalone'
    end
  end
end
