require 'rails_helper'

describe RedirectController do
  let(:group) { create(:formal_group, subdomain: "subdomain") }
  let(:discussion) { create :discussion, group: group }
  let(:poll) { create :poll, discussion: discussion }

  describe 'get group via subdomain' do
    it 'redirects to the group if the subdomain exists' do
      expect(request).to receive(:subdomain).and_return(group.subdomain)
      get :subdomain
      expect(response).to redirect_to group_url(group)
    end

    it 'responds with 404 if the subdomain does not exist' do
      get :subdomain
      expect(response.status).to eq 404
    end
  end

  it 'get group' do
    get :group, id: group.key
    expect(response).to redirect_to group_url(group)
  end

  it 'get discussion' do
    get :discussion, id: discussion.key
    expect(response).to redirect_to discussion_url(discussion)
  end

  it 'get poll' do
    get :poll, id: poll.key
    expect(response).to redirect_to poll_url(poll)
  end
end
