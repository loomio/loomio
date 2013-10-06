require 'spec_helper'

describe Discussion do
  let(:discussion) { create(:discussion) }

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

  it 'should have comments_count of 0' do
    create(:discussion).comments_count.should == 0
  end

  it "group member can add comment" do
    user = create(:user)
    discussion = create(:discussion)
    discussion.group.add_member! user
    comment = discussion.add_comment(user, "this is a test comment", uses_markdown: false)
    discussion.comments.should include(comment)
  end

  it "group non-member cannot add comment" do
    discussion = create(:discussion)
    comment = discussion.add_comment(create(:user), "this is a test comment", uses_markdown: false)
    discussion.comments.should_not include(comment)
  end

  it "automatically populates last_comment_at with discussion.created at" do
    discussion = create(:discussion)
    discussion.last_comment_at.should == discussion.created_at
  end

  describe "#search(query)" do
    before { @user = create(:user) }
    it "returns user's discussions that match the query string" do
      discussion = create(:discussion, title: "jam toast", author: @user)
      @user.discussions.search("jam").should == [discussion]
    end
    it "does not return discussions that don't belong to the user" do
      discussion = create(:discussion, title: "sandwich crumbs")
      @user.discussions.search("sandwich").should_not == [discussion]
    end
  end

  describe "#last_versioned_at" do
    it "returns the time the discussion was created at if no previous version exists" do
      Timecop.freeze do
        discussion = create :discussion
        discussion.last_versioned_at.iso8601.should == discussion.created_at.iso8601
      end
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

  describe "#activity" do
    it "returns all the activity for the discussion" do
      @user = create :user
      @group = create :group
      @group.add_member! @user
      @discussion = create :discussion, :group => @group
      @discussion.add_comment(@user, "this is a test comment", uses_markdown: false)
      @motion = create :motion, :discussion => @discussion
      @vote = create :vote, :position => 'yes', :motion => @motion
      activity = @discussion.activity
      activity[0].kind.should == 'new_discussion'
      activity[1].kind.should == 'new_comment'
      activity[2].kind.should == 'new_motion'
      activity[3].kind.should == 'new_vote'
    end
  end

  describe "#current_motion" do
    before do
      @discussion = create :discussion
      @motion = create :motion, discussion: @discussion
    end
    context "where motion is in open" do
      it "returns motion" do
        @discussion.current_motion.should eq(@motion)
      end
    end
    context "where motion close date has past" do
      before do
        @motion.closed_at = 3.days.ago
        @motion.save!
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
      @discussion.add_comment(@user2, "givin a shout out to user3!", uses_markdown: false)
      @discussion.add_comment(@user3, "thanks 4 thah love usah two!", uses_markdown: false)
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

  describe "#viewed!" do
    before do
      @discussion = create(:discussion)
    end
    it "increases the total_views by 1" do
      @discussion.total_views.should == 0
      @discussion.viewed!
      @discussion.total_views.should == 1
    end
  end

  describe "#delayed_destroy" do
    it 'sets deleted_at before calling destroy and then destroys everything' do
      @motion = create(:motion, discussion: discussion)
      @vote = create(:vote, motion: @motion)
      discussion.should_receive(:is_deleted=).with(true)
      discussion.delayed_destroy
      Discussion.find_by_id(discussion.id).should be_nil
      Motion.find_by_id(@motion.id).should be_nil
      Vote.find_by_id(@vote.id).should be_nil
    end
  end

  describe "#refresh_last_comment_at!" do
    it "resets last_comment_at to latest comment.created_at" do
      comment = discussion.add_comment discussion.author, "hi", uses_markdown: false
      comment.created_at = Time.zone.now + 2.day
      comment.save!
      discussion.update_attribute(:last_comment_at, Time.zone.now + 1.days)
      discussion.refresh_last_comment_at!
      discussion.last_comment_at.should == comment.created_at
    end

    context "no comments in discussion" do
      it "updates last_comment_at to discussion.created_at" do
        discussion.update_attribute(:last_comment_at, discussion.created_at + 1.days)
        discussion.refresh_last_comment_at!
        discussion.last_comment_at.should == discussion.created_at
      end
    end
  end
end
