require 'spec_helper'

describe Event do
  it { should belong_to(:discussion) }
  it { should allow_value("new_discussion").for(:kind) }
  it { should allow_value("new_comment").for(:kind) }
  it { should allow_value("new_vote").for(:kind) }
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
    let(:vote) { mock_model(Vote, :motion => create_motion, :user => user) }
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
        @event.notifications.where('user_id = ?', @motion.author.id).
          should exist
      end

      it "notifies discussion author" do
        @event.notifications.where('user_id = ?', discussion.author.id).
          should exist
      end

      it "does not notify motion author if they are the member who voted" do
        @vote = @motion.author.votes.new(:position => "yes")
        @vote.motion = @motion
        @vote.save!
        @event = Event.new_vote!(@vote)

        @event.notifications.where('user_id = ?', @motion.author.id).
          should_not exist
      end

      it "does not notify discussion author if they are the member who voted" do
        @vote = discussion.author.votes.new(:position => "yes")
        @vote.motion = @motion
        @vote.save!
        @event = Event.new_vote!(@vote)

        @event.notifications.where('user_id = ?', discussion.author.id).
          should_not exist
      end
    end
  end
end
