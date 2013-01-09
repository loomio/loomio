describe NotificationItem do
  describe "initialize" do
    let(:notification) { stub(:notification) }

    context "notification is for a new discussion" do
      it "returns a NewDiscussion notification item" do
        notification.stub(:event_kind).and_return("new_discussion")
        NotificationItem.new(notification).
          item.class.should == NotificationItems::NewDiscussion
      end
    end

    context "notification is for a new motion" do
      it "returns a NewMotion notification item" do
        notification.stub(:event_kind).and_return("new_motion")
        NotificationItem.new(notification).
          item.class.should == NotificationItems::NewMotion
      end
    end

    context "notification is for closed motion" do
      it "returns a MotionClosed notification item" do
        notification.stub(:event_kind).and_return("motion_closed")
        NotificationItem.new(notification).
          item.class.should == NotificationItems::MotionClosed
      end
    end

    context "notification is for a adding a new comment" do
      it "returns NewComment notification item" do
        notification.stub(:event_kind).and_return("new_comment")
        NotificationItem.new(notification).
          item.class.should == NotificationItems::NewComment
      end
    end

    context "notification is for a comment like" do
      it "returns a CommentLiked notification item" do
        notification.stub(:event_kind).and_return("comment_liked")
        NotificationItem.new(notification).
          item.class.should == NotificationItems::CommentLiked
      end
    end

    context "notification is for a membership request" do
      it "returns a MembershipRequested notification item" do
        notification.stub(:event_kind).and_return("membership_requested")
        NotificationItem.new(notification).
          item.class.should == NotificationItems::MembershipRequested
      end
    end

    context "notification is for a adding a user to a group" do
      it "returns UserAddedToGroup notification item" do
        notification.stub(:event_kind).and_return("user_added_to_group")
        NotificationItem.new(notification).
        item.class.should == NotificationItems::UserAddedToGroup
      end
    end

    context "notification is for mentioning a user" do
      it "returns MentionedUser notification item" do
        notification.stub(:event_kind).and_return("user_mentioned")
        item = NotificationItem.new(notification).
          item.class.should == NotificationItems::UserMentioned
      end
    end

    context "notification is for a motion closing soon" do
      it "returns MotionClosingSoon notification item" do
        notification.stub(:event_kind).and_return("motion_closing_soon")
        NotificationItem.new(notification).
          item.class.should == NotificationItems::MotionClosingSoon
      end
    end

    context "notification is for a new vote" do
      it "returns NewVote notification item" do
        notification.stub(:event_kind).and_return("new_vote")
        NotificationItem.new(notification).
          item.class.should == NotificationItems::NewVote
      end
    end

    context "notification is for blocked motion" do
      it "returns MotionBlocked notification item" do
        notification.stub(:event_kind).and_return("motion_blocked")
        NotificationItem.new(notification).
          item.class.should == NotificationItems::MotionBlocked
      end
    end
  end
end
