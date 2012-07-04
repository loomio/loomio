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

  it "fires new_discussion! event" do
    Event.should_receive(:new_discussion!)
    create_discussion
  end

  describe "discussion.history" do
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

  describe "discussion.participants" do
    before do
      @user1, @user2, @user3, @user4 =
        User.make!, User.make!, User.make!, User.make!
      @discussion = create_discussion(author: @user1)
      @group = @discussion.group
      @group.add_member! @user2
      @group.add_member! @user3
      @group.add_member! @user4
      @discussion.add_comment(@user2, "givin a shout out to user3!")
      @discussion.add_comment(@user3, "thanks 4 thah love usah two!")
    end

    it "should include users who have commented on discussion" do
      @discussion.participants.should include(@user2)
      @discussion.participants.should include(@user3)
    end

    it "should include the author of the discussion" do
      @discussion.participants.should include(@user1)
    end

    it "should include discussion motion authors (if any)" do
      previous_motion_author = User.make!
      current_motion_author = User.make!
      @group.add_member! previous_motion_author
      @group.add_member! current_motion_author
      previous_motion = create_motion(:discussion => @discussion,
                             :author => previous_motion_author)
      previous_motion.close_voting!
      current_motion = create_motion(:discussion => @discussion,
                             :author => current_motion_author)

      @discussion.participants.should include(previous_motion_author)
      @discussion.participants.should include(current_motion_author)
    end

    it "should not include users who have not commented on discussion" do
      @discussion.participants.should_not include(@user4)
    end
  end

end
