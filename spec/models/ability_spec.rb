require "cancan/matchers"

describe "User abilities" do
  let(:user) { User.make! }
  let(:other_user) { User.make! }

  let(:ability) { Ability.new(user) }
  subject { ability }


  context "member of a group" do
    let(:group) { Group.make! }
    let(:membership_request) { group.add_request!(User.make!) }
    let(:discussion) { create_discussion(group: group) }
    let(:new_discussion) { user.authored_discussions.new(
                           group: group, title: "new discussion") }
    let(:user_comment) { discussion.add_comment(user, "hello") }
    let(:another_user_comment) { discussion.add_comment(other_user, "hello") }
    let(:user_motion) { create_motion(author: user, discussion: discussion) }
    let(:other_users_motion) { create_motion(author: other_user, discussion: discussion) }
    let(:new_motion) { Motion.new(discussion_id: discussion.id) }

    before do
      @user_membership = group.add_member!(user)
      @other_user_membership = group.add_member!(other_user)
    end

    it { should be_able_to(:show, group) }
    it { should_not be_able_to(:update, group) }
    it { should be_able_to(:add_subgroup, group) }
    it { should be_able_to(:new_motion, group) }
    it { should be_able_to(:new_proposal, discussion) }
    it { should be_able_to(:add_comment, discussion) }
    it { should be_able_to(:index, Discussion) }
    it { should be_able_to(:destroy, user_comment) }
    it { should_not be_able_to(:destroy, another_user_comment) }
    it { should be_able_to(:like, user_comment) }
    it { should be_able_to(:like, another_user_comment) }
    it { should be_able_to(:unlike, user_comment) }
    it { should be_able_to(:unlike, another_user_comment) }
    it { should be_able_to(:create, new_discussion) }
    it { should_not be_able_to(:make_admin, @user_membership) }
    it { should_not be_able_to(:make_admin, @other_user_membership) }
    it { should_not be_able_to(:destroy, @other_user_membership) }
    it { should be_able_to(:destroy, @user_membership) }
    it { should be_able_to(:create, new_motion) }
    it { should be_able_to(:update, user_motion) }
    it { should be_able_to(:close_voting, user_motion) }
    it { should be_able_to(:open_voting, user_motion) }
    it { should be_able_to(:destroy, user_motion) }
    it { should_not be_able_to(:update, other_users_motion) }
    it { should_not be_able_to(:destroy, other_users_motion) }
    it { should_not be_able_to(:close_voting, other_users_motion) }
    it { should_not be_able_to(:open_voting, other_users_motion) }

    it "cannot delete the only member of a group" do
      @other_user_membership.destroy
      should_not be_able_to(:destroy, @user_membership)
    end

    context "group members invitable by members" do
      before { group.update_attributes(:members_invitable_by => :members) }
      it { should be_able_to(:add_members, group) }
      it { should be_able_to(:approve_request, membership_request) }
      it { should be_able_to(:ignore_request, membership_request) }
      it { should_not be_able_to(:destroy, @other_user_membership) }
    end

    context "group members invitable by admins" do
      before { group.update_attributes(:members_invitable_by => :admins) }
      it { should_not be_able_to(:add_members, group) }
      it { should_not be_able_to(:approve_request, membership_request) }
      it { should_not be_able_to(:ignore_request, membership_request) }
    end

    context "group viewable by members" do
      before { group.update_attributes(:viewable_by => :members) }
      it { should be_able_to(:show, group) }
    end

    context "viewing a subgroup they do not belong to" do
      let(:subgroup) { Group.make!(parent: group) }
      context "subgroup viewable by members" do
        before { subgroup.update_attributes(:viewable_by => :members) }
        it { should_not be_able_to(:show, subgroup) }
      end
      context "subgroup viewable by parent group members" do
        before { subgroup.update_attributes(:viewable_by => :parent_group_members) }
        it { should be_able_to(:show, subgroup) }
      end
    end
  end


  context "admin of a group" do
    let(:group) { Group.make! }
    let(:discussion) { create_discussion(group: group) }
    let(:other_users_motion) { create_motion(author: other_user, discussion: discussion) }

    before do
      @user_membership = group.add_admin! user
      @other_user_membership = group.add_member! other_user
      @membership_request = group.add_request! User.make!
    end

    it { should be_able_to(:update, group) }
    it { should be_able_to(:make_admin, @membership_request) }
    it { should be_able_to(:remove_admin, @membership_request) }
    it { should be_able_to(:destroy, @other_user_membership) }
    it { should_not be_able_to(:update, other_users_motion) }
    it { should be_able_to(:destroy, other_users_motion) }
    it { should be_able_to(:close_voting, other_users_motion) }
    it { should be_able_to(:open_voting, other_users_motion) }

    it "should not be able to delete the only admin of a group" do
      should_not be_able_to(:destroy, @user_membership)
    end

    context "group members invitable by admins" do
      before { group.update_attributes(:members_invitable_by => :admins) }
      it { should be_able_to(:add_members, group) }
      it { should be_able_to(:approve_request, @membership_request) }
    end
  end


  context "non-member of a group" do
    let(:group) { Group.make! }
    let(:discussion) { create_discussion(group: group) }
    let(:new_motion) { Motion.new(discussion_id: discussion.id) }
    let(:motion) { create_motion(discussion: discussion) }
    let(:new_discussion) { user.authored_discussions.new(
                           group: group, title: "new discussion") }
    let(:another_user_comment) { discussion.add_comment(discussion.author, "hello") }

    it { should_not be_able_to(:update, group) }
    it { should_not be_able_to(:add_subgroup, group) }
    it { should_not be_able_to(:add_members, group) }
    it { should_not be_able_to(:new_proposal, discussion) }
    it { should_not be_able_to(:add_comment, discussion) }
    it { should be_able_to(:index, Discussion) }
    it { should_not be_able_to(:destroy, another_user_comment) }
    it { should_not be_able_to(:like, another_user_comment) }
    it { should_not be_able_to(:unlike, another_user_comment) }
    it { should_not be_able_to(:create, new_discussion) }
    it { should_not be_able_to(:create, new_motion) }
    it { should_not be_able_to(:close_voting, motion) }
    it { should_not be_able_to(:open_voting, motion) }
    it { should_not be_able_to(:update, motion) }
    it { should_not be_able_to(:destroy, motion) }

    context "group viewable_by: everyone" do
      before { group.update_attributes(:viewable_by => :everyone) }
      it { should be_able_to(:show, group) }
    end
    context "group viewable_by: members" do
      before { group.update_attributes(:viewable_by => :members) }
      it { should_not be_able_to(:show, group) }
    end
  end
end
