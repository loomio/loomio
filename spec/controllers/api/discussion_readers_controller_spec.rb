require 'rails_helper'
describe API::DiscussionReadersController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }
  let(:reader_params) { { volume: :mute } }

  before do
    group.add_admin! user
    sign_in user
    reader.save
    reader.reload
  end

  describe 'update' do
    context 'success' do
      it "updates a discussion reader's volume" do
        post :update, id: reader.discussion.id, discussion_reader: reader_params
        expect(response).to be_success
        expect(reader.reload.volume.to_sym).to eq reader_params[:volume]
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
