require 'rails_helper'

describe GroupService::PrivacyChange do
  describe 'getting private' do
    let(:group) { FactoryBot.create(:group, group_privacy: 'open') }
    let(:subgroup) { create(:group, parent: group, group_privacy: 'open') }
    let(:other_subgroup) { create(:group, parent: group, group_privacy: 'open') }

    before do
      create(:discussion, group: group, private: false)
      # create a public discussion in that subgroup
      create(:discussion, group: subgroup, private: false)
      create(:discussion, group: other_subgroup, private: false)
    end

    describe 'is_visible_to_public changes to false' do
      before do
        group.is_visible_to_public = false
        privacy_change = GroupService::PrivacyChange.new(group)
        group.save!
        privacy_change.commit!
      end

      it "makes discussions in the group and subgroups private" do
        expect(Discussion.where(group_id: group.id_and_subgroup_ids).all?(&:private?)).to be true
      end

      it "makes all public subgroups closed, visible to parent members" do
        expect(group.subgroups.all?{|g| g.group_privacy == 'closed'}).to be true
        expect(group.subgroups.all?{|g| g.is_hidden_from_public?}).to be true
        expect(group.subgroups.all?{|g| g.is_visible_to_parent_members?}).to be true
      end
    end

    describe 'discussion_privacy_options changes to private_only' do
      before do
        group.group_privacy = 'closed'
        group.discussion_privacy_options = 'private_only'
        privacy_change = GroupService::PrivacyChange.new(group)
        group.save!
        privacy_change.commit!
      end

      it "makes discussions in the group private" do
        expect(group.discussions.all?(&:private?)).to be true
      end
    end
  end

  describe 'getting public' do
    let(:group) { FactoryBot.create(:group, group_privacy: 'secret') }

    before do
      create(:discussion, group: group, private: true)
    end

    describe 'is_visible_to_public changes to true' do
      # do nothing I think
    end

    describe 'discussion_privacy_options changes to public_only' do
      before do
        group.group_privacy = 'open'
        privacy_change = GroupService::PrivacyChange.new(group)
        group.save!
        privacy_change.commit!
      end

      it "makes discussions in the group public" do
        expect(group.discussions.all?(&:public?)).to be true
      end
    end
  end
end
