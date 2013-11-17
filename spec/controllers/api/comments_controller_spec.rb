require 'spec_helper'
describe Api::CommentsController do
  describe 'creating a comment' do
    render_views
    let(:user) { create :user }
    let(:group) { create :group }
    let(:discussion) { create :discussion, group: group }
    let(:comment_params) { {body: 'hello', discussion_id: discussion.id} }

    before do
      group.admins << user
      sign_in user
    end

    it "creates a comment" do
      post :create, comment: comment_params
      response.should be_success
    end

    it 'returns the comment json', focus: true do
      post :create, comment: comment_params
      JSON.parse(response.body).keys.should include *(%w[body author created_at updated_at])
    end
  end

end
