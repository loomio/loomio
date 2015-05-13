require 'rails_helper'
describe API::DiscussionReadersController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:comment) { build(:comment, discussion: discussion) }
  let(:discussion) { create :discussion, group: group }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }
  let(:reader_params) { { volume: :mute, starred: true } }

  before do
    group.add_admin! user
    sign_in user
    reader.save
    reader.reload
  end

  describe 'mark_as_read', focus: true do
    it "Marks context/discusion as read" do
      patch :mark_as_read, id: discussion.key, sequence_id: 0
      expect(reader.reload.last_read_at).to eq discussion.reload.last_activity_at
      expect(reader.last_read_sequence_id).to eq 0
    end

    it "Marks thread item as read", focus: true do
      event = CommentService.create(comment: comment, actor: discussion.author)
      patch :mark_as_read, id: discussion.key, sequence_id: event.reload.sequence_id
      expect(reader.reload.last_read_at).to eq event.created_at
      expect(reader.last_read_sequence_id).to eq 1
    end
  end

  describe 'update' do
    context 'success' do
      it "updates a discussion reader's volume" do
        post :update, id: reader.discussion.id, discussion_reader: reader_params
        expect(response).to be_success
        expect(reader.reload.volume.to_sym).to eq reader_params[:volume]
      end

      it "updates a discussion reader's star status" do
        post :update, id: reader.discussion.id, discussion_reader: reader_params
        expect(response).to be_success
        expect(reader.reload.starred).to be_truthy
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        reader_params[:dontmindme] = 'wild wooly byte virus'
        put :update, id: discussion.id, discussion_reader: reader_params
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        put :update, id: discussion.id, discussion_reader: reader_params
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end

      it "responds with validation errors when they exist" do
        reader_params[:volume] = 'wark'
        put :update, id: discussion.id, discussion_reader: reader_params
        json = JSON.parse(response.body)
        expect(response.status).to eq 422
        expect(json['errors']['volume']).to include 'is not a valid value'
      end
    end
  end

end
