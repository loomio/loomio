require 'rails_helper'
describe Group do
  let(:group) { create(:group) }

  describe "group_privacy" do
    it 'gets values for "open" correctly' do
      group.is_visible_to_public = true
      group.discussion_privacy_options = 'public_only'
      expect(group.group_privacy).to eq 'open'
    end

    it 'gets values for "closed" correctly' do
      group.is_visible_to_public = true
      group.discussion_privacy_options = 'public_or_private'
      expect(group.group_privacy).to eq 'closed'
      group.discussion_privacy_options = 'private_only'
      expect(group.group_privacy).to eq 'closed'

    end

    it 'gets values for "secret" correctly' do
      group.is_visible_to_public = false
      expect(group.group_privacy).to eq 'secret'
    end
  end

  describe "group_privacy=" do
    describe 'open' do
      before do
        # set it to invalid options to confirm it sets correct ones
        group.is_visible_to_public = false
        group.discussion_privacy_options = 'public_or_private'
        group.group_privacy = 'open'
      end

      it "is visible to public and public discussions only" do
        expect(group.is_visible_to_public).to eq true
        expect(group.discussion_privacy_options).to eq 'public_only'
      end

      describe 'membership_granted_upon' do
        it 'allows request' do
          group.membership_granted_upon = 'request'
          group.group_privacy = 'open'
          expect(group.membership_granted_upon).to eq 'request'
        end

        it 'allows approval' do
          group.membership_granted_upon = 'approval'
          group.group_privacy = 'open'
          expect(group.membership_granted_upon).to eq 'approval'
        end

        it 'does not allow invitation' do
          # membership_granted_upon request is allowed
          group.membership_granted_upon = 'invitation'
          group.group_privacy = 'open'
          expect(group.membership_granted_upon).to eq 'approval'
        end
      end
    end

    describe "closed" do
      before do
        # set it to invalid options to confirm it sets correct ones
        group.membership_granted_upon = 'approval'
        group.is_visible_to_public = false
        group.discussion_privacy_options = 'public_only'
        group.group_privacy = 'closed'
      end

      it "sets is visible to public to be true and private discussions only" do
        expect(group.is_visible_to_public).to eq true
        expect(group.discussion_privacy_options).to eq 'private_only'
        expect(group.membership_granted_upon).to eq 'approval'
      end

      describe 'discussion_privacy_options' do
        it "allows public_or_private" do
          group.discussion_privacy_options = 'public_or_private'
          group.group_privacy = 'closed'
          expect(group.discussion_privacy_options).to eq 'public_or_private'
        end
        it "allows private_only" do
          group.discussion_privacy_options = 'private_only'
          group.group_privacy = 'closed'
          expect(group.discussion_privacy_options).to eq 'private_only'
        end

        it "does not allow public_only" do
          group.discussion_privacy_options = 'public_only'
          group.group_privacy = 'closed'
          expect(group.discussion_privacy_options).to eq 'private_only'
        end
      end

      describe "closed subgroup of secret parent" do
        let(:secret_parent) { create(:group, group_privacy: 'secret')}
        let(:group) { create(:group, parent: secret_parent, group_privacy: 'closed')}

        it "is visible_to_parent_members and not visible to public" do
          expect(group.is_visible_to_public).to eq false
          expect(group.is_visible_to_parent_members).to eq true
        end
      end
    end

    describe 'secret' do
      before do
        # set it to invalid options to confirm it sets correct ones
        group.membership_granted_upon = 'approval'
        group.is_visible_to_public = true
        group.is_visible_to_parent_members = true
        group.discussion_privacy_options = 'public_only'
        group.group_privacy = 'secret'
      end

      it 'sets visible_to_public = false, membership by invitation, disussions private only' do
        expect(group.is_visible_to_public).to eq false
        expect(group.discussion_privacy_options).to eq 'private_only'
        expect(group.membership_granted_upon).to eq 'invitation'
        expect(group.is_visible_to_parent_members).to eq false
      end
    end
  end
end
