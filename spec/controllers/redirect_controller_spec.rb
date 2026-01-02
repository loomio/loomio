require 'rails_helper'

describe RedirectController do
  let(:group) { create(:group, handle: "handle") }
  let(:discussion) { create :discussion, group: group }
  let(:poll) { create :poll, discussion: discussion }

  it 'get group' do
    get :group, params: { id: group.key }
    expect(response).to redirect_to "/g/#{group.key}"
  end

  it 'get discussion' do
    get :discussion, params: { id: discussion.key }
    expect(response).to redirect_to discussion_path(discussion)
  end

  # it 'get poll' do
  #   get :poll, params: { id: poll.key }
  #   expect(response).to redirect_to poll_url(poll)
  # end
end
