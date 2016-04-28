require 'rails_helper'

describe DiscussionReader do

  let(:user) { FactoryGirl.create :user }
  let(:other_user) { FactoryGirl.create :user }
  let(:group) { FactoryGirl.create :group }
  let(:discussion) { FactoryGirl.create :discussion, group: group }
  let(:membership) { FactoryGirl.create :membership, user: user, group: group, volume: :normal }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }

  describe 'volume' do
    it 'can change its volume' do
      reader.set_volume! :loud
      expect(reader.reload.volume.to_sym).to eq :loud
    end

    it 'defaults to the memberships volume when nil' do
      expect(membership.volume).to eq reader.volume
    end
  end

  describe 'viewed!' do
    it 'publishes a simple serialized discussion' do
      expect(MessageChannelService).to receive(:publish)
      reader.viewed!
    end
  end

end
