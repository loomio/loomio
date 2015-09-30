require 'rails_helper'

describe API::NotificationsController do

  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:discussion) { create(:discussion, author: user) }
  let(:comment) { build(:comment, discussion: discussion, body: "Hello @#{user.username}") }

  before do
    discussion.group.users << another_user
    sign_in user
    CommentService.create(comment: comment, actor: another_user)
  end

  describe 'index' do

    context 'success' do
      it 'does not serialize out null values for discussion readers' do
        get :index
        json = JSON.parse(response.body)
        discussion_json = json['discussions'][0]
        expect(json['discussions'][0].keys).not_to include 'discussion_reader_id'
      end
    end
  end

end
