require 'rails_helper'

include Dev::FakeDataHelper

describe 'DemoService' do
  let(:actor) { create(:user) }
  let(:group) { saved(fake_group) }

  describe 'clone_group' do

    it 'creates a new group' do
      clone = DemoService.clone_group(group: group, actor: actor)

      %w[
        name
        description
        description_format
        members_can_add_members
        members_can_edit_discussions
        members_can_edit_comments
        members_can_raise_motions
        members_can_vote
        members_can_start_discussions
        members_can_create_subgroups
        members_can_announce
        new_threads_max_depth
        new_threads_newest_first
        admins_can_edit_user_content
        members_can_add_guests
        members_can_delete_comments
        link_previews
      ].each do |field|
        expect(clone.send(field)).to eq group.send(field)
      end


      expect(clone.id).to be_present
      expect(clone.handle).to be nil
      expect(clone.creator_id).to eq actor.id
      expect(clone.is_visible_to_public).to be false
      expect(clone.is_visible_to_parent_members).to be false
      expect(clone.discussion_privacy_options).to eq 'private_only'
      expect(clone.membership_granted_upon).to eq 'approval'
      expect(clone.listed_in_explore).to be false
      expect(clone.secret_token.present?).to be true
      expect(clone.secret_token).not_to eq group.secret_token

      # check that the group has copied the tags
      expect(clone.tags.map(&:id)).not_to eq group.tags.map(&:id)
      expect(clone.tags.map(&:name)).to eq group.tags.map(&:name)

      expect(clone.subscription.plan).to eq 'demo'

      expect(clone.creator).to eq actor
    end
  end
end
