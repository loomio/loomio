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
      reader.viewed!(discussion.last_activity_at)
    end
  end

  describe 'dismissed!' do
    it 'publishes a simple serialized discussion' do
      expect(MessageChannelService).to receive(:publish)
      reader.dismiss!
    end
  end

  describe 'viewed' do
    let!(:other_membership) { create(:membership, user: other_user, group: group) }
    let!(:older_item) { CommentService.create(comment: build(:comment, discussion: discussion, created_at: 5.days.ago), actor: other_user) }
    let!(:newer_item) { CommentService.create(comment: build(:comment, discussion: discussion, created_at: 2.days.ago), actor: other_user) }
    before do
      reader.update(last_read_at: 6.days.ago,
                    last_read_sequence_id: 0,
                    read_items_count: 0,
                    read_salient_items_count: 0)
    end

    it 'updates the counts correctly from existing last_read_at' do
      reader.viewed!(discussion.last_activity_at)
      expect(reader.last_read_sequence_id).to eq 2
      expect(reader.read_items_count).to eq 2
      expect(reader.read_salient_items_count).to eq 2
    end

    it 'updates the existing counts correctly from a given last_read_at' do
      reader.viewed!(3.days.ago)
      expect(reader.last_read_sequence_id).to eq 1
      expect(reader.read_items_count).to eq 1
      expect(reader.read_salient_items_count).to eq 1
    end

    it 'updates the existing counts correctly from a recent last_read_at' do
      reader.viewed!(1.day.ago)
      expect(reader.last_read_sequence_id).to eq 2
      expect(reader.read_items_count).to eq 2
      expect(reader.read_salient_items_count).to eq 2
    end

    it 'does not do anything for an old last_read_at' do
      reader.viewed!(7.days.ago)
      expect(reader.last_read_sequence_id).to eq 0
      expect(reader.read_items_count).to eq 0
      expect(reader.read_salient_items_count).to eq 0
    end

    it 'updates to fully read even if never read before' do
      reader.update(last_read_at: nil)
      reader.viewed!(discussion.last_activity_at)
      expect(reader.last_read_sequence_id).to eq 2
      expect(reader.read_items_count).to eq 2
      expect(reader.read_salient_items_count).to eq 2
    end

    it 'does not do anything if last_read_at does not exist and is not given' do
      reader.update(last_read_at: nil)
      reader.viewed!(nil)
      expect(reader.last_read_sequence_id).to eq 0
      expect(reader.read_items_count).to eq 0
      expect(reader.read_salient_items_count).to eq 0
    end
  end

end
