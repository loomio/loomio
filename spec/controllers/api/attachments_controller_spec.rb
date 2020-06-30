require 'rails_helper'

describe API::AttachmentsController do
  let(:user)  { create :user }
  let(:group) { create :group }
  let(:another_group) { create :group, parent: group }
  let(:discussion) { create :discussion, group: group }

  before do
    sign_in user
    discussion.files.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'strongbad.png')),
                            filename: 'strongbad.png',
                            content_type: 'image/jpeg')
    discussion.files.last.update_attribute(:group_id, discussion.group_id)
    @attachment = discussion.files.last
  end

  describe 'destroy' do
    it 'allowed if admin' do
      group.add_admin! user
      delete :destroy, params: { id: @attachment.id }
      expect(response.status).to eq 200
      # json = JSON.parse(response.body)
      # expect(json).to be_empty
    end

    it 'disallowed if not admin' do
      delete :destroy, params: { id: @attachment.id }
      expect(response.status).to eq 403
    end
  end
end
