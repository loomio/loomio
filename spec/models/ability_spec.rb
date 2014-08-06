require "cancan/matchers"
require 'rails_helper'

describe "User abilities" do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:non_member) { create(:user) }
  let(:group) { create(:group) }

  let(:ability) { Ability.new(user) }
  subject { ability }

  let(:own_invitation) { InvitationService.create_invite_to_join_group(recipient_email: "h@h.com",
                                                                       group: group,
                                                                       inviter: user) }
  let(:other_members_invitation) { InvitationService.create_invite_to_join_group(recipient_email: "h@h.com",
                                                                                 group: group,
                                                                                 inviter: other_user) }
  it { should     be_able_to(:create, group) }
  
  context "in relation to a group" do
    describe "is_visible_to_public?" do
      context "true" do
        before { group.update_attribute(:is_visible_to_public, true) }

        describe "non member" do
          it {should be_able_to(:show, group)}
        end

        describe "member" do
          before { group.add_member!(user) }

          it {should be_able_to(:show, group)}
        end
      end

      context "false" do
        before { group.update_attribute(:is_visible_to_public, false) }

        describe "non member" do
          it {should_not be_able_to(:show, group)}
        end

        describe "member" do
          before { group.add_member!(user) }
          it {should be_able_to(:show, group)}
        end
      end
    end

    describe "is_visible_to_parent_members?" do
      let(:parent_group) { create(:group) }

      before do
        group.update_attribute(:is_visible_to_public, false)
        group.parent = parent_group
        group.save
      end

      context "true" do
        before { group.update_attribute(:is_visible_to_parent_members, true) }

        describe "non member" do
          it { should_not be_able_to(:show, group) }
        end

        describe "member of parent only" do
          before { parent_group.add_member!(user) }
          it {should be_able_to(:show, group)}
        end

        describe "member of subgroup only" do
          before { group.add_member!(user) }
          it {should be_able_to(:show, group)}
        end
      end

      context "false" do
        before { group.update_attribute(:is_visible_to_parent_members, false) }

        describe "non member" do
          it { should_not be_able_to(:show, group) }
        end

        describe "member of parent only" do
          before { parent_group.add_member!(user) }
          it {should_not be_able_to(:show, group)}
        end

        describe "member of subgroup only" do
          before { group.add_member!(user) }
          it {should be_able_to(:show, group)}
        end
      end
    end

    describe "members_can_add_members?" do

      context "true" do
        before { group.update_attribute(:members_can_add_members, true) }

        describe "non member of group" do
          it {should_not be_able_to(:add_members, group)}
        end

        describe "member of group" do
          before { group.add_member!(user) }
          it {should be_able_to(:add_members, group)}
        end

        describe "admin of group" do
          before { group.add_admin!(user) }
          it {should be_able_to(:add_members, group)}
        end
      end

      context "false" do
        before { group.update_attribute(:members_can_add_members, false) }

        describe "non member of group" do
          it {should_not be_able_to(:add_members, group)}
        end

        describe "member of group" do
          before { group.add_member!(user) }
          it {should_not be_able_to(:add_members, group)}
        end

        describe "admin of group" do
          before { group.add_admin!(user) }
          it {should be_able_to(:add_members, group)}
        end
      end
    end

    context "member of group", focus: true do
      before { group.add_member!(user) }

      describe "members_can_start_discussions" do
        let(:discussion) { Discussion.new(group: group) }

        context "true" do
          before { group.update_attribute(:members_can_start_discussions, true) }
          it {should be_able_to(:create, discussion)}
        end

        context "false" do
          before { group.update_attribute(:members_can_start_discussions, false) }
          it {should_not be_able_to(:create, discussion)}
        end
      end

      describe "members_can_raise_motions" do
        let(:discussion) { FactoryGirl.create(:discussion, group: group, author: user) }
        let(:motion) { Motion.new(discussion: discussion) }

        context "true" do
          before { group.update_attribute(:members_can_raise_motions, true) }
          it {should be_able_to(:create, motion)}
        end

        context "false" do
          before { group.update_attribute(:members_can_raise_motions, false) }
          it {should_not be_able_to(:create, motion)}
        end
      end

      describe "members_can_vote" do
        let(:discussion) { FactoryGirl.create(:discussion, group: group, author: user) }
        let(:motion) { FactoryGirl.create(:motion, discussion: discussion) }

        context "true" do
          before { group.update_attribute(:members_can_vote, true) }
          it {should be_able_to(:vote, motion)}
        end

        context "false" do
          before { group.update_attribute(:members_can_vote, false) }
          it {should_not be_able_to(:vote, motion)}
        end
      end

      # start_subgroups
      describe "members_can_create_subgroups" do
        let(:subgroup) { Group.new(parent: group) }

        context "true" do
          before { group.update_attribute(:members_can_create_subgroups, true) }
          it {should be_able_to(:create, subgroup)}
        end

        context "false" do
          before { group.update_attribute(:members_can_create_subgroups, false) }
          it {should_not be_able_to(:create, subgroup)}
        end
      end
    end
  end

  context "suspended member" do
    let(:group) { create(:group) }
    let(:admin_group) { create(:group) }
    let(:subgroup) { create(:group, parent: group) }
    let(:private_discussion) { create :discussion, group: group, private: true }


    context "group is visible to public" do
      let(:group) { create(:group, is_visible_to_public: true) }

      before do
        membership = group.add_member!(user)
        MembershipService.suspend_membership!(membership: membership)
      end

      it { should be_able_to(:show, group) }
      it { should_not be_able_to(:show, private_discussion) }
      it "is no longer a group member" do
        group.reload
        group.members.should_not include user
      end
    end

    context "group is hidden from public" do
      let(:group) { create(:group, is_visible_to_public: false) }

      before do
        membership = group.add_member!(user)
        MembershipService.suspend_membership!(membership: membership)
      end

      it { should_not be_able_to(:show, group) }
    end
  end

  context "member of a group" do
    let(:group) { create(:group) }
    let(:subgroup) { build(:group, parent: group) }
    let(:subgroup_for_another_group) { build(:group, parent: create(:group)) }
    let(:membership_request) { create(:membership_request, group: group, requestor: non_member) }
    let(:discussion) { create :discussion, group: group }
    let(:user_discussion) { create :discussion, group: group, author: user }
    let(:new_discussion) { user.authored_discussions.new(
                           group: group, title: "new discussion") }
    let(:user_comment) { discussion.add_comment(user, "hello") }
    let(:another_user_comment) { discussion.add_comment(other_user, "hello") }
    let(:user_motion) { create(:motion, author: user, discussion: discussion) }
    let(:user_vote) { create(:vote, user: user, motion: user_motion)}
    let(:other_users_motion) { create(:motion, author: other_user, discussion: discussion) }
    let(:new_motion) { Motion.new(discussion_id: discussion.id) }
    let(:closed_motion) { create(:motion, discussion: discussion, closed_at: 1.day.ago) }

    before do
      own_invitation
      @membership = group.add_member!(user)
      @other_membership = group.add_member!(other_user)
    end

    context "members_can_edit_comments"do
      it { should be_able_to(:manage, user_comment) }
      it { should_not be_able_to(:manage, another_user_comment) }
    end

    context "members_can_not_edit_comments" do
      before do
        group.members_can_edit_comments = false
      end
      context "is most recent comment" do
        it { should be_able_to(:manage, user_comment) }
      end
      context "is not most recent comment" do
        before do
          user_comment
          FactoryGirl.create(:comment, discussion: discussion, author: other_user)
        end
        it { should_not be_able_to(:manage, user_comment) }
      end
    end


    context "members_can_edit_discussions" do
      before do
        group.members_can_edit_discussions = true
      end
      it { should be_able_to(:update, discussion) }
    end

    context "members_can_not_edit_discussions" do
      before do
        group.members_can_edit_discussions = false
      end
      it { should_not be_able_to(:update, discussion) }
    end

    describe "motions_can_be_edited" do
      context "true" do
        before do
          group.update_attributes(motions_can_be_edited: true)
        end
        context "a vote has been cast" do
          before { user_vote }
          context "can change text" do
            before do
              user_motion.name = "name change"
              user_motion.description = "description change"
            end

            it { should be_able_to(:update, user_motion) }
          end
        end
      end

      context "false" do
        before do
          group.update_attributes(motions_can_be_edited: false)
        end

        context "a vote has been cast" do
          before { user_vote }
          context "cannot change text" do
            before do
              user_motion.name = "name change"
              user_motion.description = "description change"
            end

            it { should_not be_able_to(:update, user_motion) }
          end

          context "can change closing_at" do
            before do
              user_motion.closing_at = 44.days.from_now
            end

            it { should be_able_to(:update, user_motion) }
          end
        end

        context "no votes yet" do
          it { should be_able_to(:update, user_motion) }
        end
      end
    end


    it { should     be_able_to(:create, subgroup) }
    it { should     be_able_to(:show, group) }
    it { should_not be_able_to(:update, group) }
    it { should_not be_able_to(:email_members, group) }
    it { should     be_able_to(:add_subgroup, group) }
    it { should     be_able_to(:create, subgroup) }
    it { should_not be_able_to(:create, subgroup_for_another_group) }
    it { should_not be_able_to(:view_payment_details, group) }
    it { should_not be_able_to(:choose_subscription_plan, group) }
    it { should     be_able_to(:new_proposal, discussion) }
    it { should     be_able_to(:add_comment, discussion) }
    it { should     be_able_to(:show_description_history, discussion) }
    it { should     be_able_to(:preview_version, discussion) }
    it { should_not be_able_to(:update_version, discussion) }
    it { should     be_able_to(:update_version, user_discussion) }
    it { should_not be_able_to(:move, discussion) }
    it { should     be_able_to(:update, user_discussion) }
    it { should     be_able_to(:show, Discussion) }
    it { should     be_able_to(:unfollow, Discussion) }
    it { should     be_able_to(:destroy, user_comment) }
    it { should_not be_able_to(:destroy, discussion) }
    it { should_not be_able_to(:destroy, another_user_comment) }
    it { should     be_able_to(:like, Comment) }
    it { should     be_able_to(:create, new_discussion) }
    it { should_not be_able_to(:make_admin, @membership) }
    it { should_not be_able_to(:make_admin, @other_membership) }
    it { should_not be_able_to(:destroy, @other_membership) }
    it { should     be_able_to(:destroy, @membership) }
    it { should     be_able_to(:create, new_motion) }
    it { should     be_able_to(:close, user_motion) }
    it { should     be_able_to(:create_outcome, user_motion) }
    it { should     be_able_to(:destroy, user_motion) }
    it { should_not be_able_to(:destroy, other_users_motion) }
    it { should_not be_able_to(:close, other_users_motion) }
    it { should_not be_able_to(:create_outcome, other_users_motion) }

    it { should     be_able_to(:vote, user_motion) }
    it { should     be_able_to(:vote, other_users_motion) }
    it { should_not be_able_to(:vote, closed_motion) }

    it { should     be_able_to(:cancel, own_invitation) }
    it { should_not be_able_to(:cancel, other_members_invitation) }

    it { should be_able_to(:show, user_comment) }
    it { should be_able_to(:show, user_motion) }
    it { should be_able_to(:show, user_vote) }

    it "cannot remove themselves if they are the only member of the group" do
      group.memberships.where("memberships.id != ?", @membership.id).destroy_all
      should_not be_able_to(:destroy, @membership)
    end

    context "members can add members" do
      before { group.update_attribute(:members_can_add_members, true) }
      it { should     be_able_to(:add_members, group) }
      it { should     be_able_to(:invite_people, group) }
      it { should     be_able_to(:manage_membership_requests, group) }
      it { should     be_able_to(:approve, membership_request) }
      it { should     be_able_to(:ignore, membership_request) }
      it { should_not be_able_to(:destroy, @other_membership) }
    end

    context "members cannot add members" do
      before { group.update_attribute(:members_can_add_members, false) }
      it { should_not be_able_to(:add_members, group) }
      it { should_not be_able_to(:invite_people, group) }
      it { should_not be_able_to(:manage_membership_requests, group) }
      it { should_not be_able_to(:approve, membership_request) }
      it { should_not be_able_to(:ignore, membership_request) }
      it { should_not be_able_to(:destroy, @other_membership) }
    end
  end

  context "admin of a group" do
    let(:group) { create(:group) }
    let(:discussion) { create :discussion, group: group }
    let(:another_user_comment) { discussion.add_comment(other_user, "hello", uses_markdown: false) }
    let(:other_users_motion) { create(:motion, author: other_user, discussion: discussion) }
    let(:membership_request) { create(:membership_request, group: group, requestor: non_member) }

    before do
      @membership = group.add_admin! user
      @other_membership = group.add_member! other_user
    end

    it { should     be_able_to(:update, group) }
    it { should     be_able_to(:email_members, group) }
    it { should     be_able_to(:hide_next_steps, group) }
    it { should     be_able_to(:view_payment_details, group) }
    it { should     be_able_to(:choose_subscription_plan, group) }
    it { should     be_able_to(:destroy, discussion) }
    it { should     be_able_to(:move, discussion) }
    it { should     be_able_to(:update, discussion) }
    it { should     be_able_to(:make_admin, @other_membership) }
    it { should     be_able_to(:remove_admin, @other_membership) }
    it { should     be_able_to(:destroy, @other_membership) }
    it { should     be_able_to(:update, other_users_motion) }
    it { should     be_able_to(:destroy, other_users_motion) }
    it { should     be_able_to(:close, other_users_motion) }
    it { should     be_able_to(:create_outcome, other_users_motion) }
    it { should     be_able_to(:destroy, another_user_comment) }
    it { should     be_able_to(:cancel, own_invitation) }
    it { should     be_able_to(:cancel, other_members_invitation) }

    it "should not be able to delete the only admin of a group" do
      group.admin_memberships.where("memberships.id != ?", @membership.id).destroy_all
      should_not be_able_to(:destroy, @membership)
    end

    context "group members invitable by admins" do
      before { group.update_attribute(:members_can_add_members, false) }
      it { should     be_able_to(:add_members, group) }
      it { should     be_able_to(:invite_people, group) }
      it { should     be_able_to(:manage_membership_requests, group) }
      it { should     be_able_to(:approve, membership_request) }
      it { should     be_able_to(:ignore, membership_request) }
    end

    context "where group is marked as manual subscription" do
      before { group.update_attributes(payment_plan: 'manual_subscription') }
      it { should_not be_able_to(:view_payment_details, group) }
      it { should_not be_able_to(:choose_subscription_plan, group) }
    end
  end

  context "non-member of a group" do

    context 'hidden group' do
      let(:group) { create(:group, is_visible_to_public: false) }
      let(:discussion) { create :discussion, group: group, private: true }
      let(:new_motion) { Motion.new(discussion_id: discussion.id) }
      let(:motion) { create(:motion, discussion: discussion) }
      let(:vote) { create(:vote, user: discussion.author, motion: motion) }
      let(:new_discussion) { user.authored_discussions.new(
                             group: group, title: "new discussion") }
      let(:another_user_comment) { discussion.add_comment(discussion.author, "hello", uses_markdown: false) }
      let(:my_membership_request) { create(:membership_request, group: group, requestor: user) }
      let(:other_membership_request) { create(:membership_request, group: group, requestor: other_user) }

      it { should_not be_able_to(:show, group) }
      it { should_not be_able_to(:update, group) }
      it { should_not be_able_to(:email_members, group) }
      it { should_not be_able_to(:add_subgroup, group) }
      it { should_not be_able_to(:add_members, group) }
      it { should_not be_able_to(:hide_next_steps, group) }
      it { should_not be_able_to(:unfollow, group) }
      it { should_not be_able_to(:create, new_discussion) }
      it { should_not be_able_to(:show, discussion) }
      it { should_not be_able_to(:new_proposal, discussion) }
      it { should_not be_able_to(:add_comment, discussion) }
      it { should_not be_able_to(:move, discussion) }
      it { should_not be_able_to(:destroy, discussion) }
      it { should_not be_able_to(:like_comments, discussion) }
      it { should_not be_able_to(:create, new_motion) }
      it { should_not be_able_to(:close, motion) }
      it { should_not be_able_to(:edit_close_date, motion) }
      it { should_not be_able_to(:open, motion) }
      it { should_not be_able_to(:update, motion) }
      it { should_not be_able_to(:destroy, motion) }
      it { should_not be_able_to(:destroy, another_user_comment) }
      it { should_not be_able_to(:vote, motion) }
      it { should_not be_able_to(:show, another_user_comment) }
      it { should_not be_able_to(:show, motion) }
      it { should_not be_able_to(:show, vote) }
    end

    context "public group" do
      let(:group) { create(:group, is_visible_to_public: true) }
      let(:private_discussion) { create :discussion, group: group, private: true }
      let(:public_discussion) { create :discussion, group: group, private: false }
      let(:new_motion) { Motion.new(discussion_id: private_discussion.id) }
      let(:motion) { create(:motion, discussion: private_discussion) }
      let(:new_discussion) { user.authored_discussions.new(
                             group: group, title: "new discussion") }
      let(:another_user_comment) { private_discussion.add_comment(private_discussion.author, "hello", uses_markdown: false) }
      let(:my_membership_request) { create(:membership_request, group: group, requestor: user) }
      let(:other_membership_request) { create(:membership_request, group: group, requestor: other_user) }

      it { should     be_able_to(:show, group) }
      it { should_not be_able_to(:view_payment_details, group) }
      it { should_not be_able_to(:choose_subscription_plan, group) }
      it { should_not be_able_to(:update, group) }
      it { should_not be_able_to(:email_members, group) }
      it { should_not be_able_to(:add_subgroup, group) }
      it { should_not be_able_to(:add_members, group) }
      it { should_not be_able_to(:manage_membership_requests, group) }
      it { should_not be_able_to(:hide_next_steps, group) }
      it { should_not be_able_to(:unfollow, group) }

      it { should     be_able_to(:cancel, my_membership_request) }
      it { should_not be_able_to(:cancel, other_membership_request) }
      it { should_not be_able_to(:approve, other_membership_request) }
      it { should_not be_able_to(:ignore, other_membership_request) }

      it { should_not be_able_to(:create, new_discussion) }
      it { should_not be_able_to(:show, private_discussion) }
      it { should_not be_able_to(:new_proposal, private_discussion) }
      it { should_not be_able_to(:add_comment, private_discussion) }
      it { should_not be_able_to(:move, private_discussion) }
      it { should_not be_able_to(:destroy, private_discussion) }

      it { should     be_able_to(:show, public_discussion) }
      it { should_not be_able_to(:new_proposal, public_discussion) }
      it { should_not be_able_to(:add_comment, public_discussion) }
      it { should_not be_able_to(:move, public_discussion) }
      it { should_not be_able_to(:destroy, public_discussion) }

      it { should_not be_able_to(:destroy, another_user_comment) }
      it { should_not be_able_to(:like, another_user_comment) }
      it { should_not be_able_to(:unlike, another_user_comment) }

      it { should_not be_able_to(:create, new_motion) }
      it { should_not be_able_to(:close, motion) }
      it { should_not be_able_to(:edit_close_date, motion) }
      it { should_not be_able_to(:open, motion) }
      it { should_not be_able_to(:update, motion) }
      it { should_not be_able_to(:destroy, motion) }
    end
  end

  context "Loomio admin deactivates other_user" do
    before do
      user.is_admin = true
    end
    let(:group) { create(:group) }

    context "other_user is a member of a group with many members" do
      before do
        group.add_member!(other_user)
      end
      it { should     be_able_to(:deactivate, other_user) }
    end

    context "other_user is the only coordinator of one of their groups" do
      before do
        group.admins.destroy_all
        group.add_admin!(other_user)
      end
      it { should_not be_able_to(:deactivate, other_user) }
    end
  end
end
