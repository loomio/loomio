require 'rails_helper'

describe 'GroupService' do
  let(:user) { create(:user) }
  let(:group) { build(:group) }

  describe 'create' do
    it 'assigns a default group cover' do
      default = create(:default_group_cover)
      GroupService.create(group: group, actor: user)
      expect(group.reload.cover_photo.url).to eq default.cover_photo.url
    end

    it 'does not assign a default group cover if none have been defined' do
      GroupService.create(group: group, actor: user)
      expect(group.reload.cover_photo).to be_blank
    end
  end
end
