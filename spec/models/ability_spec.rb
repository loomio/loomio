require "cancan/matchers"
require 'rails_helper'

describe "User abilities" do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:non_member) { create(:user) }
  let(:group) { create(:group) }

  let(:ability) { Ability::Base.new(user) }
  subject { ability }

  let(:own_pending_membership) {
    create :membership, user: create(:user, email: "i@i.com", email_verified: false), group: group, inviter: user
  }
  let(:other_members_pending_membership) {
    create :membership, user: create(:user, email: "h@h.com", email_verified: false), group: group, inviter: other_user
  }
  it { should be_able_to(:create, group) }

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
      let(:subgroup) { create(:group, parent: group, is_visible_to_public: false) }

      context "true" do
        before { subgroup.update_attribute(:is_visible_to_parent_members, true) }

        describe "non member" do
          it { should_not be_able_to(:show, subgroup) }
        end

        describe "member of parent only" do
          before { group.add_member!(user) }
          it {should be_able_to(:show, subgroup)}
        end

        describe "member of subgroup only" do
          before { subgroup.add_member!(user) }
          it {should be_able_to(:show, subgroup)}
        end

        context "parent_members_can_see_discussions" do
          let(:discussion) { create(:discussion, group: subgroup, private: true) }
          before { group.add_member!(user) }

          context "true" do
            before do
              subgroup.update_attribute(:parent_members_can_see_discussions, true)
            end
            it {should be_able_to(:show, discussion)}
          end

          context "false" do
            before do
              subgroup.update_attribute(:parent_members_can_see_discussions, false)
            end

            it {should_not be_able_to(:show, discussion)}
          end
        end
      end

      context "false" do
        before { subgroup.update_attribute(:is_visible_to_parent_members, false) }

        describe "non member" do
          it { should_not be_able_to(:show, subgroup) }
        end

        describe "member of parent only" do
          before { group.add_member!(user) }
          it {should_not be_able_to(:show, subgroup)}
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

    context "member of group" do
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

      # start_subgroups
      describe "members_can_create_subgroups" do
        let(:subgroup) { build(:group, parent: group) }

        context "true" do
          before { group.update_attribute(:members_can_create_subgroups, true) }
          it {should be_able_to(:create, subgroup)}
          it {should be_able_to(:add_subgroup, group)}
        end

        context "false" do
          before { group.update_attribute(:members_can_create_subgroups, false) }
          it {should_not be_able_to(:create, subgroup)}
          it {should_not be_able_to(:add_subgroup, group)}
        end
      end
    end
  end

  context "member of a group" do
    let(:group) { create(:group) }
    let(:subgroup) { build(:group, parent: group) }
    let(:subgroup_for_another_group) { build(:group, parent: create(:group)) }
    let(:membership_request) { create(:membership_request, group: group, requestor: non_member) }
    let(:discussion) { create :discussion, group: group }
    let(:comment) { build :comment, discussion: discussion, author: user }
    let(:user_discussion) { create :discussion, group: group, author: user }
    let(:new_discussion) { user.authored_discussions.new(
                           group: group, title: "new discussion") }
    let(:user_comment) { create :comment, discussion: discussion, author: user }
    let(:another_user_comment) { create :comment, discussion: discussion }

    before do
      own_pending_membership
      @membership = group.add_member!(user)
      @other_membership = group.add_member!(other_user)
    end

    context "members_can_edit_comments"do
      it { should be_able_to(:update, user_comment) }
      it { should_not be_able_to(:update, another_user_comment) }
    end

    context "members_can_not_edit_comments" do
      before do
        group.update members_can_edit_comments: false
      end
      context "is most recent comment" do
        it { should be_able_to(:update, user_comment) }
      end
      context "is not most recent comment" do
        before do
          user_comment
          FactoryBot.create(:comment, discussion: discussion, author: other_user)
        end
        it { should_not be_able_to(:update, user_comment) }
      end
    end


    context "members_can_edit_discussions" do
      before do
        group.update members_can_edit_discussions: true
      end
      it { should be_able_to(:update, discussion) }
    end

    context "members_can_not_edit_discussions" do
      before do
        group.update members_can_edit_discussions: false
      end
      it { should_not be_able_to(:update, discussion) }
    end

    it { should     be_able_to(:show, group) }
    it { should_not be_able_to(:update, group) }
    it { should_not be_able_to(:email_members, group) }
    it { should_not be_able_to(:create, subgroup_for_another_group) }
    it { should     be_able_to(:create, comment) }
    it { should     be_able_to(:show_description_history, discussion) }
    it { should     be_able_to(:preview_version, discussion) }
    it { should_not be_able_to(:update_version, discussion) }
    it { should     be_able_to(:update_version, user_discussion) }
    it { should_not be_able_to(:move, discussion) }
    it { should     be_able_to(:move, user_discussion) }
    it { should     be_able_to(:update, user_discussion) }
    it { should     be_able_to(:show, Discussion) }
    it { should     be_able_to(:print, Discussion) }
    it { should     be_able_to(:destroy, user_comment) }
    it { should_not be_able_to(:destroy, discussion) }
    it { should_not be_able_to(:destroy, another_user_comment) }
    it { should     be_able_to(:create, new_discussion) }
    it { should_not be_able_to(:make_admin, @membership) }
    it { should_not be_able_to(:make_admin, @other_membership) }
    it { should_not be_able_to(:destroy, @other_membership) }
    it { should     be_able_to(:destroy, @membership) }

    it { should     be_able_to(:destroy, own_pending_membership) }
    it { should_not be_able_to(:destroy, other_members_pending_membership) }

    it { should be_able_to(:show, user_comment) }

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
    let(:subgroup) { create(:group, parent: group) }
    let(:closed_subgroup) { create(:group, parent: group, group_privacy: 'closed') }
    let(:discussion) { create :discussion, group: group }
    let(:another_user_comment) { create :comment, discussion: discussion, user: other_user }
    let(:membership_request) { create(:membership_request, group: group, requestor: non_member) }

    before do
      @membership = group.add_admin! user
      @subgroup_membership = subgroup.add_member! user
      @other_membership = group.add_member! other_user
    end

    it { should     be_able_to(:update, group) }
    it { should     be_able_to(:email_members, group) }
    it { should     be_able_to(:destroy, discussion) }
    it { should     be_able_to(:move, discussion) }
    it { should     be_able_to(:update, discussion) }
    it { should     be_able_to(:make_admin, @other_membership) }
    it { should     be_able_to(:make_admin, @subgroup_membership) }
    it { should     be_able_to(:remove_admin, @other_membership) }
    it { should     be_able_to(:destroy, @other_membership) }
    it { should     be_able_to(:destroy, another_user_comment) }
    it { should     be_able_to(:destroy, own_pending_membership) }
    it { should     be_able_to(:destroy, other_members_pending_membership) }

    it "should be able to join a closed subgroup" do
      should be_able_to(:join, closed_subgroup)
    end

    it "should be able to become admin if no admins" do
      @membership.update(admin: false)
      group.admin_memberships.destroy_all
      should be_able_to(:make_admin, @membership)
    end

    it "should not be able to become admin if other admins" do
      @membership.update(admin: false)
      should_not be_able_to(:make_admin, @membership)
    end

    context "group members invitable by admins" do
      before { group.update_attribute(:members_can_add_members, false) }
      it { should     be_able_to(:add_members, group) }
      it { should     be_able_to(:invite_people, group) }
      it { should     be_able_to(:manage_membership_requests, group) }
      it { should     be_able_to(:approve, membership_request) }
      it { should     be_able_to(:ignore, membership_request) }
    end
  end

  context 'non member of hidden group' do
    let(:group) { create(:group, is_visible_to_public: false) }
    let(:discussion) { create :discussion, group: group, private: true }
    let(:new_discussion) { Discussion.new(group: group, author: user, title: 'title') }
    let(:user_comment) { Comment.new discussion: discussion, author: user }
    let(:another_user_comment) { create :comment, discussion: discussion, author: other_user }
    let(:my_membership_request) { create(:membership_request, group: group, requestor: user) }
    let(:other_membership_request) { create(:membership_request, group: group, requestor: other_user) }

    it { should_not be_able_to(:show, group) }
    it { should_not be_able_to(:update, group) }
    it { should_not be_able_to(:email_members, group) }
    it { should_not be_able_to(:add_members, group) }
    it { should_not be_able_to(:hide_next_steps, group) }
    it { should_not be_able_to(:unfollow, group) }
    it { should_not be_able_to(:create, new_discussion) }
    it { should_not be_able_to(:show, discussion) }
    it { should_not be_able_to(:print, discussion) }
    it { should_not be_able_to(:create, user_comment) }
    it { should_not be_able_to(:move, discussion) }
    it { should_not be_able_to(:destroy, discussion) }
    it { should_not be_able_to(:like, another_user_comment) }
    it { should_not be_able_to(:destroy, another_user_comment) }
    it { should_not be_able_to(:show, another_user_comment) }
  end

  context "non member of public group" do
    let(:group) { create(:group, is_visible_to_public: true, discussion_privacy_options: 'public_or_private') }
    let(:private_discussion) { create :discussion, group: group, private: true }
    let(:comment_in_private_discussion) { Comment.new discussion: private_discussion, author: user, body: 'hi' }
    let(:public_discussion) { create :discussion, group: group, private: false }
    let(:comment_in_public_discussion) { Comment.new discussion: public_discussion, author: user, body: 'hi' }
    let(:new_discussion) { user.authored_discussions.new(
                           group: group, title: "new discussion") }
    let(:another_user_comment) { create :comment, discussion: private_discussion }
    let(:my_membership_request) { create(:membership_request, group: group, requestor: user) }
    let(:other_membership_request) { create(:membership_request, group: group, requestor: other_user) }

    it { should     be_able_to(:show, group) }
    it { should_not be_able_to(:update, group) }
    it { should_not be_able_to(:email_members, group) }
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
    it { should_not be_able_to(:print, private_discussion) }
    it { should_not be_able_to(:create, comment_in_private_discussion) }
    it { should_not be_able_to(:move, private_discussion) }
    it { should_not be_able_to(:destroy, private_discussion) }

    it { should     be_able_to(:show, public_discussion) }
    it { should     be_able_to(:print, public_discussion) }
    it { should_not be_able_to(:create, comment_in_public_discussion) }
    it { should_not be_able_to(:move, public_discussion) }
    it { should_not be_able_to(:destroy, public_discussion) }

    it { should_not be_able_to(:destroy, another_user_comment) }
    it { should_not be_able_to(:like, another_user_comment) }
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

  end
end
