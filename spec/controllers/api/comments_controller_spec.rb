require 'spec_helper'
describe Api::CommentsController do
  render_views

  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }

  before do
    group.admins << user
    sign_in user
  end

  describe 'creating a comment' do
    let(:comment_params) { {body: 'hello', discussion_id: discussion.id} }

    it "creates a comment" do
      post :create, comment: comment_params
      response.should be_success
    end

    it 'returns the comment json', focus: true do
      post :create, comment: comment_params
      JSON.parse(response.body).keys.should include *(%w[id sequence_id kind comment])
      JSON.parse(response.body)['comment'].keys.should include *(%w[body author created_at])
    end
  end

  describe 'like' do
    before do
      comment = Comment.new(discussion: discussion,
                            author: user,
                            body: 'hi')

      event = DiscussionService.add_comment(comment)
      @comment = event.eventable
    end

    it 'adds a like from the current user', focus: true do
      DiscussionService.should_receive(:like_comment).with(user, @comment)
      post :like, id: @comment.id
    end

    it 'returns the current user id and name as json' do
      DiscussionService.stub(:like_comment)
      post :like, id: @comment.id
      JSON.parse(response.body).keys.should include *(%w[id name])
    end
  end
end
