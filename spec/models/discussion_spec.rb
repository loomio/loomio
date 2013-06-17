require 'spec_helper'

describe Discussion do
  it { should have_many(:events).dependent(:destroy) }
  it { should respond_to(:uses_markdown) }
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
    comment = discussion.add_comment(user, "this is a test comment", false)
    discussion.comment_threads.should include(comment)
  end

  it "group non-member cannot add comment" do
    discussion = create(:discussion)
    comment = discussion.add_comment(create(:user), "this is a test comment", false)
    discussion.comment_threads.should_not include(comment)
  end

  it "automatically populates last_comment_at with discussion.created at" do
    discussion = create(:discussion)
    discussion.last_comment_at.should == discussion.created_at
  end

  describe "#latest_comment_time" do
    it "returns time of latest comment if comments exist" do
      discussion = create :discussion
      discussion.stub :comments => {:count => 1}
      comment = stub :created_at => 12345
      comment = discussion.stub_chain(:comments, :order, :first).
                           and_return(comment)
      discussion.latest_comment_time.should == 12345
    end
    it "returns time of discussion creation if no comments exist" do
      discussion = create :discussion
      discussion.latest_comment_time.should == discussion.created_at
    end
  end

  describe "#last_versioned_at" do
    it "returns the time the discussion was created at if no previous version exists" do
      discussion = create :discussion
      discussion.last_versioned_at.should == discussion.created_at
    end
    it "returns the time the previous version was created at" do
      discussion = create :discussion
      discussion.stub :has_previous_versions? => true
      discussion.stub_chain(:previous_version, :version, :created_at)
                .and_return 12345
      discussion.last_versioned_at.should == 12345
    end
  end

  context "versioning" do
    before do
      @discussion = create(:discussion)
      @version_count = @discussion.versions.count
    end

    it "doesn't create a new version when unrelevant attribute is edited" do
      @discussion.update_attribute :author, create(:user)
      @discussion.should have(@version_count).versions
    end

    it "creates a new version when discussion.description is edited" do
      @discussion.update_attribute :description, "new description"
      @discussion.should have(@version_count + 1).versions
    end
  end

  describe "#never_read_by(user)" do
    before do
      @discussion = create :discussion
    end
    it "should retuen true if user is logged out" do
      @discussion.never_read_by(@user).should == true
    end
    it "returns true if dicussion has never been read" do
      @user = create :user
      @discussion.stub(:read_log_for).with(@user).and_return(nil)
      @discussion.never_read_by(@user).should == true
    end
    it "returns false if user has visited the discussion page" do
      @user = create :user
      @discussion.stub(:read_log_for).with(@user).and_return(true)
      @discussion.never_read_by(@user).should == false
    end
  end

  describe "#activity" do
    it "returns all the activity for the discussion" do
      @user = create :user
      @group = create :group
      @group.add_member! @user
      @discussion = create :discussion, :group => @group
      @discussion.add_comment(@user, "this is a test comment", false)
      @motion = create :motion, :discussion => @discussion
      @vote = create :vote, :position => 'yes', :motion => @motion
      activity = @discussion.activity
      activity[0].kind.should == 'new_vote'
      activity[1].kind.should == 'new_motion'
      activity[2].kind.should == 'new_comment'
    end
  end

  describe "#filtered_activity" do
    before do
      @user = create :user
      @group = create :group
      @group.add_member! @user
      @discussion = create :discussion, :group => @group
      @discussion.set_description!("describy", false, @user)
      @discussion.set_description!("describe", false, @user)
      @discussion.add_comment(@user, "this is a test comment", false)
    end
    context "there are duplicate events" do
      it "keeps them in the activity list" do
        activity = @discussion.activity
        activity[0].kind.should == 'new_comment'
        activity[1].kind.should == 'discussion_description_edited'
        activity[2].kind.should == 'discussion_description_edited'
        activity[3].kind.should == 'new_discussion'
      end
      it "removes them from the filtered_activity list" do
        filtered_activity = @discussion.filtered_activity
        filtered_activity[0].kind.should == 'new_comment'
        filtered_activity[1].kind.should == 'discussion_description_edited'
        filtered_activity[2].kind.should == 'new_discussion'
      end
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
        @motion.close_at_date = (Date.today - 3.day).strftime("%d-%m-%Y")
        @motion.close_at_time = "12:00"
        @motion.close_at_time_zone = "Wellington"
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
      @discussion.add_comment(@user2, "givin a shout out to user3!", false)
      @discussion.add_comment(@user3, "thanks 4 thah love usah two!", false)
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
      previous_motion.close!
      current_motion = create(:motion, :discussion => @discussion,
                             :author => current_motion_author)

      @discussion.participants.should include(previous_motion_author)
      @discussion.participants.should include(current_motion_author)
    end

    it "should not include users who have not commented on discussion" do
      @discussion.participants.should_not include(@user4)
    end
  end

  describe "#update_total_views" do
    before do
      @discussion = create(:discussion)
    end
    it "increases the total_views by 1" do
      @discussion.total_views.should == 0
      @discussion.update_total_views
      @discussion.total_views.should == 1
    end
  end

  describe "last_looked_at_by(user)" do
    before do
      @user = stub_model(User)
      @discussion = build :discussion
      @discussion_read_log = mock_model(DiscussionReadLog)
    end
    context "the user has not read the discussion" do
      it "returns the date the user joined the group" do
        @discussion.stub(:read_log_for).with(@user).and_return(nil)
        @discussion.last_looked_at_by(@user).should == nil
      end
    end
    context "and has read the discussion" do
      it "returns the date the discussion was last viewed" do
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

  describe "#delayed_destroy" do
    it 'sets deleted_at before calling destroy' do
      @discussion = create(:discussion)
      @discussion.should_receive(:is_deleted=).with(true)
      @discussion.delayed_destroy
    end
  end
end
