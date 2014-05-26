require "cancan/matchers"
require 'spec_helper'

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

  context "member of a group" do
    let(:group) { create(:group) }
    let(:subgroup) { build(:group, parent: group) }
    let(:subgroup_for_another_group) { build(:group, parent: create(:group)) }
    let(:membership_request) { create(:membership_request, group: group, requestor: non_member) }
    let(:discussion) { create_discussion group: group }
    let(:user_discussion) { create_discussion group: group, author: user }
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
    it { should     be_able_to(:update_description, discussion) }
    it { should     be_able_to(:edit_description, group) }
    it { should     be_able_to(:show_description_history, discussion) }
    it { should     be_able_to(:preview_version, discussion) }
    it { should     be_able_to(:update_version, discussion) }
    it { should_not be_able_to(:move, discussion) }
    it { should_not be_able_to(:update, discussion) }
    it { should     be_able_to(:update, user_discussion) }
    it { should     be_able_to(:show, Discussion) }
    it { should     be_able_to(:unfollow, Discussion) }
    it { should     be_able_to(:destroy, user_comment) }
    it { should_not be_able_to(:destroy, discussion) }
    it { should_not be_able_to(:destroy, another_user_comment) }
    it { should     be_able_to(:like_comments, discussion) }
    it { should     be_able_to(:create, new_discussion) }
    it { should_not be_able_to(:make_admin, @membership) }
    it { should_not be_able_to(:make_admin, @other_membership) }
    it { should_not be_able_to(:destroy, @other_membership) }
    it { should     be_able_to(:destroy, @membership) }
    it { should     be_able_to(:create, new_motion) }
    it { should     be_able_to(:close, user_motion) }
    it { should     be_able_to(:create_outcome, user_motion) }
    it { should     be_able_to(:edit_close_date, user_motion) }
    it { should     be_able_to(:destroy, user_motion) }
    it { should_not be_able_to(:destroy, other_users_motion) }
    it { should_not be_able_to(:close, other_users_motion) }
    it { should_not be_able_to(:create_outcome, other_users_motion) }
    it { should_not be_able_to(:edit_close_date, other_users_motion) }

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

    context "group members invitable by members" do
      before { group.update_attributes(:members_invitable_by => 'members') }
      it { should     be_able_to(:add_members, group) }
      it { should     be_able_to(:invite_people, group) }
      it { should     be_able_to(:manage_membership_requests, group) }
      it { should     be_able_to(:approve, membership_request) }
      it { should     be_able_to(:ignore, membership_request) }
      it { should_not be_able_to(:destroy, @other_membership) }
    end

    context "group members invitable by admins" do
      before { group.update_attributes(:members_invitable_by => 'admins') }
      it { should_not be_able_to(:add_members, group) }
      it { should_not be_able_to(:invite_people, group) }
      it { should_not be_able_to(:manage_membership_requests, group) }
      it { should_not be_able_to(:approve, membership_request) }
      it { should_not be_able_to(:ignore, membership_request) }
    end

    context "that is hidden" do
      before { group.update_attributes(:privacy => 'hidden') }
      it { should     be_able_to(:show, group) }

      context "with hidden subgroup" do
        before do
          subgroup.update_attributes(privacy: 'hidden', viewable_by_parent_members: false)
          subgroup.add_member!(user)
        end

        context "invitable by members" do
          before { subgroup.update_attributes(:members_invitable_by => 'members') }
          it { should_not be_able_to(:invite_outsiders, subgroup) }
          it { should     be_able_to(:invite_people, subgroup) }
        end

        context "invitable by admins only" do
          before { subgroup.update_attributes(:members_invitable_by => 'admins') }
          it { should_not be_able_to(:invite_outsiders, subgroup) }
          it { should_not be_able_to(:invite_people, subgroup) }
        end
      end
    end

    context "viewing a subgroup they do not belong to" do
      let(:subgroup) { create(:group, parent: group) }
      let(:private_subgroup_discussion) { create_discussion group: subgroup, private: true }
      let(:public_subgroup_discussion) { create_discussion group: subgroup, private: false }

      context "public subgroup" do
        before { subgroup.update_attributes(:privacy => 'public') }
        it { should     be_able_to(:show, subgroup) }
        it { should     be_able_to(:request_membership, subgroup) }
        it { should_not be_able_to(:show, private_subgroup_discussion) }
        it { should     be_able_to(:show, public_subgroup_discussion) }
      end

      context "private subgroup" do
        before { subgroup.update_attributes(:privacy => 'private') }
        it { should     be_able_to(:show, subgroup) }
        it { should     be_able_to(:request_membership, subgroup) }
        it { should_not be_able_to(:show, private_subgroup_discussion) }
        it { should     be_able_to(:show, public_subgroup_discussion) }
      end

      context "private subgroup viewable by parent members" do
        before { subgroup.update_attributes(:privacy => 'private', viewable_by_parent_members: true) }
        it { should     be_able_to(:show, subgroup) }
        it { should     be_able_to(:request_membership, subgroup) }
        it { should     be_able_to(:show, private_subgroup_discussion) }
        it { should     be_able_to(:show, public_subgroup_discussion) }
      end

      context "hidden subgroup" do
        before { subgroup.update_attributes(privacy: 'hidden') }
        it { should_not be_able_to(:show, subgroup) }
        it { should_not be_able_to(:request_membership, subgroup) }
        it { should_not be_able_to(:show, private_subgroup_discussion) }
      end

      context "hidden subgroup viewable by parent members" do
        before { subgroup.update_attributes(privacy: 'hidden', viewable_by_parent_members: true) }
        it { should     be_able_to(:show, subgroup) }
        it { should     be_able_to(:request_membership, subgroup) }
        it { should     be_able_to(:show, private_subgroup_discussion) }
      end
    end
  end

  context "admin of a group" do
    let(:group) { create(:group) }
    let(:discussion) { create_discussion group: group }
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
    it { should     be_able_to(:edit_description, group) }
    it { should_not be_able_to(:update, other_users_motion) }
    it { should     be_able_to(:destroy, other_users_motion) }
    it { should     be_able_to(:close, other_users_motion) }
    it { should     be_able_to(:create_outcome, other_users_motion) }
    it { should     be_able_to(:edit_close_date, other_users_motion) }
    it { should     be_able_to(:destroy, another_user_comment) }
    it { should     be_able_to(:cancel, own_invitation) }
    it { should     be_able_to(:cancel, other_members_invitation) }

    it "should not be able to delete the only admin of a group" do
      group.admin_memberships.where("memberships.id != ?", @membership.id).destroy_all
      should_not be_able_to(:destroy, @membership)
    end

    context "group members invitable by admins" do
      before { group.update_attributes(:members_invitable_by => 'admins') }
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

  context "admin of a subgroup" do
    let(:group) { create(:group) }
    let(:sub_group) { create(:group, parent: group) }
    before do
      group.add_member! user
      sub_group.add_admin! user
    end
    it { should_not be_able_to(:view_payment_details, sub_group) }
    it { should_not be_able_to(:choose_subscription_plan, sub_group) }
    it { should     be_able_to(:invite_outsiders, sub_group) }
  end

  context "non-member of a group" do

    context 'hidden group' do
      let(:group) { create(:group, privacy: 'hidden') }
      let(:discussion) { create_discussion group: group, private: true }
      let(:new_motion) { Motion.new(discussion_id: discussion.id) }
      let(:motion) { create(:motion, discussion: discussion) }
      let(:vote) { create(:vote, user: discussion.author, motion: motion) }
      let(:new_discussion) { user.authored_discussions.new(
                             group: group, title: "new discussion") }
      let(:another_user_comment) { discussion.add_comment(discussion.author, "hello", uses_markdown: false) }
      let(:my_membership_request) { create(:membership_request, group: group, requestor: user) }
      let(:other_membership_request) { create(:membership_request, group: group, requestor: other_user) }

      it { should_not be_able_to(:show, group) }
      it { should_not be_able_to(:request_membership, group) }
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
      let(:group) { create(:group, privacy: 'public') }
      let(:private_discussion) { create_discussion group: group, private: true }
      let(:public_discussion) { create_discussion group: group, private: false }
      let(:new_motion) { Motion.new(discussion_id: private_discussion.id) }
      let(:motion) { create(:motion, discussion: private_discussion) }
      let(:new_discussion) { user.authored_discussions.new(
                             group: group, title: "new discussion") }
      let(:another_user_comment) { private_discussion.add_comment(private_discussion.author, "hello", uses_markdown: false) }
      let(:my_membership_request) { create(:membership_request, group: group, requestor: user) }
      let(:other_membership_request) { create(:membership_request, group: group, requestor: other_user) }

      it { should     be_able_to(:show, group) }
      it { should     be_able_to(:request_membership, group) }
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

    context "private group" do
      let(:group) { create(:group, privacy: 'private') }
      let(:private_discussion) { create_discussion group: group, private: true }
      let(:public_discussion) { create_discussion group: group, private: false }
      let(:new_motion) { Motion.new(discussion_id: private_discussion.id) }
      let(:motion) { create(:motion, discussion: private_discussion) }
      let(:new_discussion) { user.authored_discussions.new(
                             group: group, title: "new discussion") }
      let(:another_user_comment) { private_discussion.add_comment(private_discussion.author, "hello", uses_markdown: false) }
      let(:my_membership_request) { create(:membership_request, group: group, requestor: user) }
      let(:other_membership_request) { create(:membership_request, group: group, requestor: other_user) }

      it { should     be_able_to(:show, group) }
      it { should     be_able_to(:request_membership, group) }
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

    context "subgroup viewable to parent members" do
      let(:group) { create :group}
      let(:subgroup) { create(:group, parent: group, privacy: 'hidden',
                              viewable_by_parent_members: true) }
      it { should_not be_able_to(:show, subgroup) }
      it { should_not be_able_to(:request_membership, subgroup) }
    end

    context "subgroup which is non-hidden" do
      let(:group) { create :group}
      let(:subgroup) { create(:group, parent: group, privacy: 'private') }

      it { should be_able_to(:request_membership, subgroup) }
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
