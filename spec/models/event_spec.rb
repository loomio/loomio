require 'spec_helper'

describe Event do
  it { should belong_to(:discussion) }
  it { should belong_to(:comment) }
  it { should belong_to(:motion) }
  it { should belong_to(:vote) }
  it { should belong_to(:membership) }
  it { should have_many(:notifications).dependent(:destroy) }
  it { should allow_value("new_discussion").for(:kind) }
  it { should allow_value("new_comment").for(:kind) }
  it { should allow_value("new_vote").for(:kind) }
  it { should allow_value("motion_blocked").for(:kind) }
  it { should allow_value("membership_requested").for(:kind) }
  it { should allow_value("user_added_to_group").for(:kind) }
  it { should_not allow_value("blah").for(:kind) }

  let(:discussion) { create_discussion }
  let(:group) { discussion.group }

  describe "new_discussion!" do
    subject { Event.new_discussion!(discussion) }

    its(:kind) { should eq("new_discussion") }
    its(:discussion) { should eq(discussion) }

    context "sending notifications" do
      it "notifies group members" do
        user = User.make!
        group = discussion.group
        group.add_member! user
        event = Event.new_discussion!(discussion)

        event.notifications.where(:user_id => user.id).should exist
      end

      it "does not notify discussion author" do
        event = Event.new_discussion!(discussion)

        event.notifications.where(:user_id => discussion.author.id).
          should_not exist
      end
    end
  end

  describe "new_comment!" do
    let(:comment) { stub_model(Comment, :discussion => discussion) }
    subject { Event.new_comment!(comment) }

    its(:kind) { should eq("new_comment") }
    its(:comment) { should eq(comment) }

    context "sending notifications" do
      before do
        @commentor, @participant, @non_participant =
          User.make!, User.make!, User.make!
        group.add_member! @commentor
        group.add_member! @participant
        group.add_member! @non_participant
        discussion.add_comment(@commentor, "hello!")
        discussion.add_comment(@participant, "hi there commentor!")
        comment = discussion.add_comment(@commentor, "fancy pantsy")
        @event = Event.new_comment!(comment)
      end

      it "notifies participants" do
        @event.notifications.where(:user_id => @participant.id).
          should exist
      end

      it "does not notify comment author" do
        @event.notifications.where(:user_id => @commentor.id).
          should_not exist
      end

      it "does not notify users who have not participated in the discussion" do
        @event.notifications.where(:user_id => @non_participant.id).
          should_not exist
      end
    end
  end

  describe "new_motion!" do
    let(:motion) { create_motion }
    subject { Event.new_motion!(motion) }

    its(:kind) { should eq("new_motion") }
    its(:motion) { should eq(motion) }

    context "sending notifications" do
      it "notifies group members" do
        group = motion.group
        @user1 = User.make!
        group.add_member! @user1
        group_size = group.users.size
        event = Event.new_motion!(motion)
        event.notifications.where(:user_id => @user1.id).should exist
      end

      it "does not notify motion author" do
        event = Event.new_motion!(motion)

        event.notifications.where(:user_id => motion.author.id).
          should_not exist
      end
    end
  end

  describe "new_vote!" do
    let(:user) { mock_model(User) }
    let(:vote) { mock_model(Vote, :motion_author => user,
                            :discussion_author => user, :user => user) }
    subject { Event.new_vote!(vote) }

    its(:kind) { should eq("new_vote") }
    its(:vote) { should eq(vote) }

    context "sending notifications" do
      before do
        @motion = create_motion(:discussion => discussion,
                                :author => User.make!)
        @user = User.make!
        @motion.group.add_member!(@user)
        @vote = @user.votes.new(:position => "yes")
        @vote.motion = @motion
        @vote.save!
        @event = Event.new_vote!(@vote)
      end

      it "notifies motion author" do
        @event.notifications.where(:user_id => @motion.author.id).
          should exist
      end

      it "notifies discussion author" do
        @event.notifications.where(:user_id => discussion.author.id).
          should exist
      end

      it "does not notify motion author if they are the member who voted" do
        @vote = @motion.author.votes.new(:position => "yes")
        @vote.motion = @motion
        @vote.save!
        @event = Event.new_vote!(@vote)

        @event.notifications.where(:user_id => @motion.author.id).
          should_not exist
      end

      it "does not notify discussion author if they are the member who voted" do
        @vote = discussion.author.votes.new(:position => "yes")
        @vote.motion = @motion
        @vote.save!
        @event = Event.new_vote!(@vote)

        @event.notifications.where(:user_id => discussion.author.id).
          should_not exist
      end
    end
  end

  describe "motion_blocked!" do
    let(:vote) { mock_model(Vote, :group_users => []) }
    subject { Event.motion_blocked!(vote) }

    its(:kind) { should eq("motion_blocked") }
    its(:vote) { should eq(vote) }

    context "sending notifications" do
      before do
        @user = User.make!
        @motion = create_motion
        @motion.group.add_member!(@user)
        @vote = @motion.author.votes.new(:position => "block")
        @vote.motion = @motion
        @vote.save!
        @event = Event.motion_blocked!(@vote)
      end

      it "notifies group members" do
        @event.notifications.where(:user_id => @user.id).
          should exist
      end

      it "does not notify blocker" do
        @event.notifications.where(:user_id => @motion.author.id).
          should_not exist
      end
    end
  end

  describe "membership_requested!" do
    let(:membership) { mock_model(Membership, :group_admins => []) }
    subject { Event.membership_requested!(membership) }

    its(:kind) { should eq("membership_requested") }
    its(:membership) { should eq(membership) }

    context "sending notifications" do
      before do
        @user, @admin1, @admin2 = User.make!, User.make!, User.make!
        @group = Group.make!
        @group.add_admin! @admin1
        @group.add_admin! @admin2
        @membership = @group.add_request! @user
        @event = Event.membership_requested! @membership
      end

      it "notifies admins" do
        @event.notifications.where(:user_id => @admin1.id).
          should exist
        @event.notifications.where(:user_id => @admin2.id).
          should exist
      end
    end
  end

  describe "user_added_to_group!" do
    let(:membership) { Group.make!.add_member! User.make! }
    subject { Event.user_added_to_group!(membership) }

    its(:kind) { should eq("user_added_to_group") }
    its(:membership) { should eq(membership) }

    context "sending notifications" do
      before do
        @group = Group.make!
        @user = User.make!
        @membership = @group.add_member! @user
        @event = Event.user_added_to_group! @membership
      end

      it "notifies user" do
        @event.notifications.where(:user_id => @user.id).
          should exist
      end

      it "sends email to user" do
        UserMailer.should_receive(:added_to_group).with(@user, @group).
          and_return(stub(deliver: true))
        @event = Event.user_added_to_group! @membership
      end
    end
  end
end
