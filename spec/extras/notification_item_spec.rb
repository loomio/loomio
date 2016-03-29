describe NotificationItem do
  describe "initialize" do
    let(:notification) { double(:notification) }

    context "notification is for a new discussion" do
      it "returns a NewDiscussion notification item" do
        allow(notification).to receive(:event_kind).and_return("new_discussion")
        expect(NotificationItem.new(notification).
          item.class).to eq NotificationItems::NewDiscussion
      end
    end

    context "notification is for a new motion" do
      it "returns a NewMotion notification item" do
        allow(notification).to receive(:event_kind).and_return("new_motion")
        expect(NotificationItem.new(notification).
          item.class).to eq NotificationItems::NewMotion
      end
    end

    context "notification is for closed motion" do
      it "returns a MotionClosed notification item" do
        allow(notification).to receive(:event_kind).and_return("motion_closed")
        expect(NotificationItem.new(notification).
          item.class).to eq NotificationItems::MotionClosed
      end
    end

    context "notification is for a adding a new comment" do
      it "returns NewComment notification item" do
        allow(notification).to receive(:event_kind).and_return("new_comment")
        expect(NotificationItem.new(notification).
          item.class).to eq NotificationItems::NewComment
      end
    end

    context "notification is for a comment like" do
      it "returns a CommentLiked notification item" do
        allow(notification).to receive(:event_kind).and_return("comment_liked")
        expect(NotificationItem.new(notification).
          item.class).to eq NotificationItems::CommentLiked
      end
    end

    context "notification is for a membership request" do
      it "returns a MembershipRequested notification item" do
        allow(notification).to receive(:event_kind).and_return("membership_requested")
        expect(NotificationItem.new(notification).
          item.class).to eq NotificationItems::MembershipRequested
      end
    end

    context "notification is for a adding a user to a group" do
      it "returns UserAddedToGroup notification item" do
        allow(notification).to receive(:event_kind).and_return("user_added_to_group")
        expect(NotificationItem.new(notification).
        item.class).to eq NotificationItems::UserAddedToGroup
      end
    end

    context "notification is for mentioning a user" do
      it "returns MentionedUser notification item" do
        allow(notification).to receive(:event_kind).and_return("user_mentioned")
        expect(item = NotificationItem.new(notification).
          item.class).to eq NotificationItems::UserMentioned
      end
    end

    context "notification is for a motion closing soon" do
      it "returns MotionClosingSoon notification item" do
        allow(notification).to receive(:event_kind).and_return("motion_closing_soon")
        expect(NotificationItem.new(notification).
          item.class).to eq NotificationItems::MotionClosingSoon
      end
    end

    context "notification is for a new vote" do
      it "returns NewVote notification item" do
        allow(notification).to receive(:event_kind).and_return("new_vote")
        expect(NotificationItem.new(notification).
          item.class).to eq NotificationItems::NewVote
      end
    end
  end
end
