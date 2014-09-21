require 'rails_helper'
describe API::DiscussionsController do
  render_views

  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:proposal) { create :motion, discussion: discussion, author: user }

  before do
    group.admins << user
    sign_in user
  end

  describe 'show' do
    it 'returns the discussion json' do
      proposal
      get :show, id: discussion.id, format: :json
      discussion = JSON.parse(response.body)['discussion']
      discussion.keys.should include *(%w[relationships id author_id event_ids title description active_proposal_id proposal_ids])
    end
  end
end
