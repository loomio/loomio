require "cancan/matchers"

describe "User" do
  describe "abilities" do
    subject { ability }
    let(:user) { User.make! }
    let(:other_user) { User.make! }
    let(:ability) { Ability.new(user, {}) }

    context "user with permissions" do
      before :each do
        @group = Group.make!
        other_user = User.make!
        @group.add_member!(user)
        @group.add_member!(other_user)
        @discussion = create_discussion(group: @group)
        @motion = create_motion(group: @group, discussion: @discussion)
        @user_comment = @discussion.add_comment(user, "hello")
        @another_user_comment = @discussion.add_comment(other_user, "hello")
      end

      it { should be_able_to(:add_comment, @discussion) }

      it { should be_able_to(:destroy, @user_comment) }
      it { should_not be_able_to(:destroy, @another_user_comment) }

      it { should be_able_to(:like, @user_comment) }
      it { should be_able_to(:like, @another_user_comment) }
      it { should be_able_to(:unlike, @user_comment) }
      it { should be_able_to(:unlike, @another_user_comment) }
    end

    context "user without permissions" do
      let(:discussion) { create_discussion }
      let(:comment) { discussion.add_comment(discussion.author, "hello") }

      it { should_not be_able_to(:add_comment, discussion) }
      it { should_not be_able_to(:destroy, comment) }
      it { should_not be_able_to(:like, comment) }
      it { should_not be_able_to(:unlike, comment) }
    end
  end
end
