require 'rails_helper'

describe RedirectController do
  describe 'get group_subdomain' do
    let(:group) { create(:group, subdomain: "subdomain") }

    it 'redirects to the group if the subdomain exists' do
      expect(request).to receive(:subdomain).and_return(group.subdomain)
      get :group_subdomain
      expect(response).to redirect_to group_url(group)
    end

    it 'responds with 404 if the subdomain does not exist' do
      get :group_subdomain
      expect(response.status).to eq 404
    end
  end
end
