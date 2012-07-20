require 'spec_helper'

describe Discussion do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:group) }
  it { should validate_presence_of(:author) }
  it { should ensure_length_of(:title).
               is_at_most(150) }

  it "author must belong to group" do
    discussion = Discussion.new(group: Group.make!)
    discussion.author = User.make!
    discussion.should_not be_valid
  end

  it "group member can add comment" do
    user = User.make!
    discussion = create_discussion
    discussion.group.add_member! user
    comment = discussion.add_comment(user, "this is a test comment")
    discussion.comment_threads.should include(comment)
  end

  it "group non-member cannot add comment" do
    discussion = create_discussion
    comment = discussion.add_comment(User.make!, "this is a test comment")
    discussion.comment_threads.should_not include(comment)
  end

  it "can update discussion_activity" do
    discussion = create_discussion
    discussion.activity = 3
    discussion.update_activity
    discussion.activity.should == 4
  end

  it "automatically populates last_comment_at with discussion.created at" do
    discussion = create_discussion
    discussion.last_comment_at.should == discussion.created_at
  end

  context "discussion.history" do
    before do
      @user = User.make
      @user.save
      @discussion = create_discussion(author: @user)
      @motion = create_motion(discussion: @discussion)
    end

    it "should include comments" do
      comment = @discussion.add_comment(@user, "this is a test comment")
      @discussion.history.should include(comment)
    end

    it "should include motions" do
      @discussion.history.should include(@discussion.current_motion)
    end

    it "should include votes" do
      vote = Vote.new(position: 'yes')
      vote.user = @user
      vote.motion = @discussion.current_motion
      vote.save
      @discussion.history.should include(vote)
    end
  end

  describe "has_activity_unread_by?(user)" do
    before do
      @user = User.make!
      @discussion = create_discussion(author: @user)
    end
    it "returns nil if user is nil" do
      user1 = nil
      @discussion.has_activity_unread_by?(user1).should == nil
    end
    it "calls discussion_activity_count(self)" do
      @user.should_receive(:discussion_activity_count).with(@discussion).
        and_return(0)

      @discussion.has_activity_unread_by?(@user)
    end
    it "returns true if user.discussion_activity_count(self) > 0" do
      @user.stub(:discussion_activity_count).with(@discussion).
        and_return(2)
      @discussion.has_activity_unread_by?(@user).should == true
    end
  end
end
