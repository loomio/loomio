require 'rails_helper'

describe API::NotificationsController do

  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:discussion) { create(:discussion, author: user) }
  let(:comment) { build(:comment, discussion: discussion, body: "Hello @#{user.username}") }
  let(:motion)  { create(:motion, discussion: discussion) }
  let(:motion_closing_soon_event) { Events::MotionClosingSoon.publish!(motion) }

  before do
    discussion.group.users << another_user
    sign_in user
  end

  describe 'index' do

    context 'success' do
      it 'does not serialize out null values for discussion readers' do
        CommentService.create(comment: comment, actor: another_user)
        get :index
        json = JSON.parse(response.body)
        discussion_json = json['discussions'][0]
        expect(json['discussions'][0].keys).not_to include 'discussion_reader_id'
      end

      it 'serializes discussions with motion_closing_soon events' do
        user.notifications.create(event: motion_closing_soon_event)
        get :index
        json = JSON.parse(response.body)
        discussion_ids = json['discussions'].map { |d| d['id'] }
        expect(discussion_ids).to include discussion.id
      end
    end
  end

end
