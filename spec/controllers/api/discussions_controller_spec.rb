require 'spec_helper'
describe Api::DiscussionsController do
  render_views

  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }

  before do
    group.admins << user
    sign_in user
  end

  describe 'creating a comment' do
    before do
      event = DiscussionService.add_comment(Comment.new(author: user, body: 'hi', discussion: discussion))
    end
    it 'returns the comment json' do
      get :show, id: discussion.id, format: :json
      raise JSON.parse(response.body)['discussion']['events'].inspect
      event.keys.should include *(%w[id sequence_id kind comment])
      event['comment'].keys.should include *(%w[body author created_at])
    end
  end
end
