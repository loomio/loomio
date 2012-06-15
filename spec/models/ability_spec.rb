require "cancan/matchers"

describe "User abilities" do
  let(:user) { User.make! }
  let(:other_user) { User.make! }
  let(:group) { Group.make! }
  let(:membership_request) { group.add_request!(User.make!) }
  let(:discussion) { create_discussion(group: group) }
  let(:new_discussion) { user.authored_discussions.new(
                         group: group, title: "new discussion") }
  let(:user_comment) { discussion.add_comment(user, "hello") }
  let(:another_user_comment) { discussion.add_comment(other_user, "hello") }

  let(:ability) { Ability.new(user) }
  subject { ability }

  context "member of a group" do
    before do
      @user_membership = group.add_member!(user)
      @other_user_membership = group.add_member!(other_user)
    end
    it { should_not be_able_to(:update, group) }
    it { should be_able_to(:new_proposal, discussion) }
    it { should be_able_to(:add_comment, discussion) }
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

    it "should not be able to delete the only member of a group" do
      @other_user_membership.destroy
      should_not be_able_to(:destroy, @user_membership)
    end

    context "group members invitable_by: members" do
      before do
        group.members_invitable_by = "members"
        group.save
      end
      it { should be_able_to(:add_members, group) }
      it { should be_able_to(:approve_request, membership_request) }
      it { should be_able_to(:ignore_request, membership_request) }
      it { should_not be_able_to(:destroy, @other_user_membership) }
    end

    context "group members invitable_by: admins" do
      before do
        group.members_invitable_by = "admins"
        group.save
      end
      it { should_not be_able_to(:add_members, group) }
      it { should_not be_able_to(:approve_request, membership_request) }
      it { should_not be_able_to(:ignore_request, membership_request) }
    end
  end

  context "admin of a group" do
    before do
      @user_membership = group.add_admin! user
      @other_user_membership = group.add_member! User.make!
      @membership_request = group.add_request! User.make!
    end

    it { should be_able_to(:make_admin, @membership_request) }
    it { should be_able_to(:remove_admin, @membership_request) }
    it { should be_able_to(:update, group) }

    it "should not be able to delete the only admin of a group" do
      should_not be_able_to(:destroy, @user_membership)
    end

    context "group members invitable_by: admins" do
      before do
        group.members_invitable_by = "admins"
        group.save
      end
      it { should be_able_to(:add_members, group) }
      it { should be_able_to(:approve_request, membership_request) }
    end
  end

  context "non-member of a group" do
    let(:group) { Group.make! }
    let(:discussion) { create_discussion(group: group) }
    let(:new_discussion) { user.authored_discussions.new(
                           group: group, title: "new discussion") }
    let(:another_user_comment) { discussion.add_comment(discussion.author, "hello") }

    it { should_not be_able_to(:add_members, group) }
    it { should_not be_able_to(:new_proposal, discussion) }
    it { should_not be_able_to(:add_comment, discussion) }
    it { should_not be_able_to(:destroy, another_user_comment) }
    it { should_not be_able_to(:like, another_user_comment) }
    it { should_not be_able_to(:unlike, another_user_comment) }
    it { should_not be_able_to(:create, new_discussion) }
  end
end
