require 'rails_helper'
describe API::AttachmentsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:comment) { create :comment, discussion: discussion}
  let(:attachment_params) {{
    title: 'Did Charlie Bite You?',
    description: 'From the dawn of internet time...',
    group_id: group.id,
    private: true
  }}

  before do
    comment.discussion.group.add_member! user
    sign_in user
  end

  describe 'create' do

    it 'creates an attachment' do
      post :create, attachment_params
    end

    context 'logged out' do
      before { @controller.stub(:current_user).and_return(LoggedOutUser.new) }

      it 'responds with forbidden for logged out users' do
        post :create, attachment_params
        expect(response.status).to eq 403
      end
    end
  end
