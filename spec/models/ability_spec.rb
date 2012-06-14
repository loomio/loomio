require "cancan/matchers"

describe "User abilities" do
  let(:user) { User.make! }
  let(:ability) { Ability.new(user, {}) }
  subject { ability }

  context "member of a group" do
    before :each do
      @other_user = User.make!
      @group = Group.make!
      @group.add_member!(user)
      @group.add_member!(@other_user)
      @discussion = create_discussion(group: @group)
      @user_comment = @discussion.add_comment(user, "hello")
      @another_user_comment = @discussion.add_comment(@other_user, "hello")
    end

    #
    # Discussions / Comments
    #

    it { should be_able_to(:new_proposal, @discussion) }
    it { should be_able_to(:add_comment, @discussion) }
    it { should be_able_to(:destroy, @user_comment) }
    it { should_not be_able_to(:destroy, @another_user_comment) }
    it { should_not be_able_to(:update, @group) }
    it { should be_able_to(:like, @user_comment) }
    it { should be_able_to(:like, @another_user_comment) }
    it { should be_able_to(:unlike, @user_comment) }
    it { should be_able_to(:unlike, @another_user_comment) }

    #
    # Groups
    #

    it { should_not be_able_to(:make_admin, @membership) }

    context "group members invitable_by: members" do
      before do
        @group.members_invitable_by = "members"
        @group.save
        @membership = @group.add_request!(User.make!)
      end
      it { should be_able_to(:add_members, @group) }
      it { should be_able_to(:approve, @membership) }
    end

    context "group members invitable_by: admins" do
      before do
        @group.members_invitable_by = "admins"
        @group.save
      end
      it { should_not be_able_to(:add_members, @group) }
      it { should_not be_able_to(:approve, @membership) }
    end
  end

  context "admin of a group" do
    before do
      @group = Group.make!
      @group.add_admin! user
      @membership = @group.add_request!(User.make!)
    end

    it { should be_able_to(:make_admin, @membership) }
    it { should be_able_to(:remove_admin, @membership) }
    it { should be_able_to(:update, @group) }

    context "group members invitable_by: admins" do
      before do
        @group.members_invitable_by = "admins"
        @group.save
      end
      it { should be_able_to(:add_members, @group) }
      it { should be_able_to(:approve, @membership) }
    end
  end

  context "non-member of a group" do
    let(:discussion) { create_discussion }
    let(:comment) { discussion.add_comment(discussion.author, "hello") }
    let(:group) { Group.make! }

    # Groups
    it { should_not be_able_to(:add_members, @group) }

    # Discussions / Comments
    it { should_not be_able_to(:new_proposal, discussion) }
    it { should_not be_able_to(:add_comment, discussion) }
    it { should_not be_able_to(:destroy, comment) }
    it { should_not be_able_to(:like, comment) }
    it { should_not be_able_to(:unlike, comment) }
  end
end
