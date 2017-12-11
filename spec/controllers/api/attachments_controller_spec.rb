require 'rails_helper'
describe API::AttachmentsController do

  let(:user) { create :user }
  let(:filename) { 'strongbad.png' }
  let(:attachment_params) {{
    file: fixture_for('images', filename)
  }}

  before do
    sign_in user
  end

  describe 'create' do

    it 'creates a new attachment' do
      post :create, params: { attachment: attachment_params }
      attachment = Attachment.last
      expect(attachment.user).to eq user
      expect(attachment.filename).to eq filename
    end

    context 'logged out' do
      before { @controller.stub(:current_user).and_return(LoggedOutUser.new) }

      it 'responds with forbidden for logged out users' do
        post :create, params: { attachment: attachment_params }
        expect(response.status).to eq 403
      end
    end
  end
end
