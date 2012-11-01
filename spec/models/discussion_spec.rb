require 'spec_helper'

describe Discussion do
  it { should have_many(:events).dependent(:destroy) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:group) }
  it { should validate_presence_of(:author) }
  it { should ensure_length_of(:title).
               is_at_most(150) }

  it "author must belong to group" do
    discussion = Discussion.new(group: create(:group))
    discussion.author = create(:user)
    discussion.should_not be_valid
  end

  it "group member can add comment" do
    user = create(:user)
    discussion = create(:discussion)
    discussion.group.add_member! user
    comment = discussion.add_comment(user, "this is a test comment")
    discussion.comment_threads.should include(comment)
  end

  it "group non-member cannot add comment" do
    discussion = create(:discussion)
    comment = discussion.add_comment(create(:user), "this is a test comment")
    discussion.comment_threads.should_not include(comment)
  end

  it "automatically populates last_comment_at with discussion.created at" do
    discussion = create(:discussion)
    discussion.last_comment_at.should == discussion.created_at
  end

  describe "#history" do
    before do
      @user = build(:user)
      @user.save
      @discussion = create(:discussion, author: @user)
      @motion = create(:motion, discussion: @discussion)
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

  describe "#current_motion" do
    before do
      @discussion = create :discussion
      @motion = create :motion, discussion: @discussion
    end
    context "where motion is in 'voting' phase" do
      it "returns motion" do
        @discussion.current_motion.should eq(@motion)
      end
    end
    context "where motion close date has past" do
      before do
        @motion.close_date = Time.now
        @motion.save
      end
      it "does not return motion" do
        @discussion.current_motion.should be_nil
      end
    end
  end

  describe "#participants" do
    before do
      @user1, @user2, @user3, @user4 =
        create(:user), create(:user), create(:user), create(:user)
      @discussion = create(:discussion, author: @user1)
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
      previous_motion_author = create(:user)
      current_motion_author = create(:user)
      @group.add_member! previous_motion_author
      @group.add_member! current_motion_author
      previous_motion = create(:motion, :discussion => @discussion,
                             :author => previous_motion_author)
      previous_motion.close_voting!
      current_motion = create(:motion, :discussion => @discussion,
                             :author => current_motion_author)

      @discussion.participants.should include(previous_motion_author)
      @discussion.participants.should include(current_motion_author)
    end

    it "should not include users who have not commented on discussion" do
      @discussion.participants.should_not include(@user4)
    end
  end

  describe "last_looked_at_by(user)" do
    before do
      @user = stub_model(User)
      @discussion = build :discussion
      @discussion_read_log = mock_model(DiscussionReadLog)
    end
    context "the user has not read the discussion" do
      it "should return the date the user joined the group" do
        @discussion.stub(:read_log_for).with(@user).and_return(nil)
        @discussion.last_looked_at_by(@user).should == nil
      end
    end
    context "and has read the discussion" do
      it "should return the date the discussion was last viewed" do
        @discussion.stub(:read_log_for).with(@user).and_return(@discussion_read_log)
        @discussion_read_log.stub(:discussion_last_viewed_at).and_return 5
        @discussion.last_looked_at_by(@user).should == 5
      end
    end
  end

  describe "has_activity_since_group_last_viewed?(user)" do
    before do
      @user = create(:user)
      @group = create(:group)
      @membership = create :membership, group: @group, user: @user
      @discussion = create :discussion, group: @group
    end
    it "returns false if user is not a member of the group" do
      @group.stub(:membership).with(@user)
      @discussion.has_activity_since_group_last_viewed?(@user).should == false
    end
    it "returns true if the discussion had comments since user last viewed their group" do
      @group.stub(:membership).with(@user).and_return(@membership)
      @group.discussions.stub_chain(:includes, :where, :count).and_return(3)
      @discussion.has_activity_since_group_last_viewed?(@user).should == true
    end
    it "returns true if the discussion is new since user last viewed their group" do
      @group.stub(:membership).with(@user).and_return(@membership)
      @group.discussions.stub_chain(:includes, :where, :count).and_return(0)
      @discussion.stub(:never_read_by).and_return(true)
      @membership.stub(:group_last_viewed_at).and_return(1)
      @discussion.stub(:created_at).and_return(2)
      @discussion.has_activity_since_group_last_viewed?(@user).should == true
    end
    it "returns false if the discussion had no activity since user last viewed their group" do
      @group.stub(:membership).with(@user).and_return(@membership)
      @group.discussions.stub_chain(:includes, :where, :count).and_return(0)
      @discussion.stub(:never_read_by).and_return(false)
      @discussion.has_activity_since_group_last_viewed?(@user).should == false
    end
  end

  describe "number_of_comments_since_last_looked(user)" do
    before do
      @user = build(:user)
      @discussion = create(:discussion)
    end
    context "the user is a member of the discussions group" do
      it "returns the total number of votes if the user has not seen the motion" do
        @discussion.stub(:last_looked_at_by).with(@user).and_return(nil)
        @discussion.stub_chain(:comments, :count).and_return(5)

        @discussion.number_of_comments_since_last_looked(@user).should == 5
      end
      it "returns the number of votes since the user last looked at the motion" do
        last_viewed_at = Time.now
        @discussion.stub(:last_looked_at_by).with(@user).and_return(last_viewed_at)
        @discussion.stub(:number_of_comments_since).with(last_viewed_at).and_return(3)

        @discussion.number_of_comments_since_last_looked(@user).should == 3
      end
    end
    context "the user is not a member of the group" do
      it "returns the total number of comments" do
        @discussion.stub(:last_looked_at_by).with(@user).and_return(nil)
        @discussion.stub_chain(:comments, :count).and_return(4)

        @discussion.number_of_comments_since_last_looked(nil).should == 4
      end
    end
  end

  describe "destroying discussion" do
    it "destroys associated comments"
  end
end
