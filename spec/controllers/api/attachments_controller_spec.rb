require 'rails_helper'

describe API::AttachmentsController do
  let(:user)  { create :user }
  let(:group) { create :group }
  let(:another_group) { create :group, parent: group }
  let(:discussion) { create :discussion, group: group }


  describe 'index' do
    before do
      discussion
      group.add_member! user
      sign_in user
    end

    it 'finds no files when not a member of the group' do
    end

    it 'finds files attached to discussions' do
      discussion.files.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'strongbad.png')),
                              filename: 'strongbad.png',
                              content_type: 'image/jpeg')
      get :index, params: {q: "stongbad"}
      json = JSON.parse(response.body)
      expect(json['attachments'][0]['name']).to eq 'strongbad.png'
    end

    it 'finds files attached to comments'
    it 'finds files attached to polls'
    it 'finds files attached to stances'
    it 'finds files attached to outcomes'
    it 'finds files attached to groups'
  end

  describe 'destroy' do
    before do
      sign_in user
      discussion.files.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'strongbad.png')),
                              filename: 'strongbad.png',
                              content_type: 'image/jpeg')
      discussion.files.last.update_attribute(:group_id, discussion.group_id)
      @attachment = discussion.files.last
    end

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
