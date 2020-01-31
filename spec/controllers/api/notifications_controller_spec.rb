require 'rails_helper'
describe API::NotificationsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :formal_group }
  let(:discussion) { create :discussion, group: group, private: false }
  let(:comment) { build(:comment, discussion: discussion, body: "hi @#{user.username}", body_format: :md) }

  before do
    group.add_admin! user
    group.add_member! another_user
    DiscussionService.create(discussion: discussion, actor: another_user)
    CommentService.create(comment: comment, actor: another_user)
    sign_in user
  end

  describe 'index' do
    context 'success' do
      it 'responds with a discussion with a reader' do
        get :index
        json = JSON.parse(response.body)
        expect(json['events'][0]['id']).to be_present
      end

    end
    #
    # context 'with comment' do
    #   before do
    #     @event = CommentService.create(comment: build(:comment, discussion: discussion), actor: user)
    #   end
    #
    #   it 'returns events beginning with a given comment id' do
    #     get :comment, params: { discussion_id: discussion.id, comment_id: @event.eventable.id }
    #     json = JSON.parse(response.body)
    #     event_ids = json['events'].map { |v| v['id'] }
    #     expect(event_ids).to include @event.id
    #   end
    #
    #   it 'returns 404 when comment not found' do
    #     get :comment, params: { discussion_id: discussion.id, comment_id: nil }
    #     expect(response.status).to eq 404
    #   end
    # end
  end
end
