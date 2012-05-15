require "cancan/matchers"

describe "User" do
  describe "abilities" do
    subject { ability }
    let(:user) { User.make! }
    let(:other_user) { User.make! }
    let(:group) { Group.make! }
    let(:ability) { Ability.new(user, {}) }

    context "member of a group" do
      before :each do
        other_user = User.make!
        group.add_member!(user)
        group.add_member!(other_user)
        @discussion = create_discussion(group: group)
        @motion = create_motion(group: group, discussion: @discussion)
        @user_comment = @discussion.add_comment(user, "hello")
        @another_user_comment = @discussion.add_comment(other_user, "hello")
      end

      #
      # Discussions / Comments
      #

      it { should be_able_to(:add_comment, @discussion) }
      it { should be_able_to(:destroy, @user_comment) }
      it { should_not be_able_to(:destroy, @another_user_comment) }
      it { should be_able_to(:like, @user_comment) }
      it { should be_able_to(:like, @another_user_comment) }
      it { should be_able_to(:unlike, @user_comment) }
      it { should be_able_to(:unlike, @another_user_comment) }

      #
      # Groups
      #

      context "group members invitable_by: members" do
        before do
          group.members_invitable_by = "members"
          group.save
        end
        it { should be_able_to(:add_members, group) }
      end

      context "group members invitable_by: admins" do
        before do
          group.members_invitable_by = "admins"
          group.save
        end
        it { should_not be_able_to(:add_members, group) }
      end
    end


    context "admin of a group" do
      before do
        group.add_admin! user
      end
      context "group members invitable_by: admins" do
        before do
          group.members_invitable_by = "admins"
          group.save
        end
        it { should be_able_to(:add_members, group) }
      end
    end


    context "non-member of a group" do
      let(:discussion) { create_discussion }
      let(:comment) { discussion.add_comment(discussion.author, "hello") }

      # Groups
      it { should_not be_able_to(:add_members, @group) }

      # Discussions / Comments
      it { should_not be_able_to(:add_comment, discussion) }
      it { should_not be_able_to(:destroy, comment) }
      it { should_not be_able_to(:like, comment) }
      it { should_not be_able_to(:unlike, comment) }
    end
  end
end
