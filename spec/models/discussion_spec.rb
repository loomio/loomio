require 'rails_helper'

describe Discussion do
  let(:discussion) { create :discussion }

  describe "archive!" do
    let(:discussion) { create :discussion }

    before do
      discussion.archive!
    end

    it "sets archived_at on the discussion" do
      discussion.archived_at.should be_present
    end
  end

  describe "#search(query)" do
    before { @user = create(:user) }
    it "returns user's discussions that match the query string" do
      discussion = create :discussion, title: "jam toast", author: @user
      expect(@user.discussions.search("jam")).to eq [discussion]
    end
    it "does not return discussions that don't belong to the user" do
      discussion = create :discussion, title: "sandwich crumbs"
      @user.discussions.search("sandwich").should_not == [discussion]
    end
  end

  describe "#last_versioned_at" do
    it "returns the time the discussion was created at if no previous version exists" do
      Timecop.freeze do
        discussion = create :discussion
        expect(discussion.last_versioned_at.iso8601).to eq discussion.created_at.iso8601
      end
    end
    it "returns the time the previous version was created at" do
      discussion = create :discussion
      discussion.stub :has_previous_versions? => true
      discussion.stub_chain(:previous_version, :version, :created_at)
                .and_return 12345
      expect(discussion.last_versioned_at).to eq 12345
    end
  end

  context "versioning" do
    before do
      @discussion = create :discussion
      @version_count = @discussion.versions.count
      PaperTrail.enabled = true
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

  describe "#motions_count" do
    before do
      @user = create(:user)
      @group = create(:group)
      @discussion = create(:discussion, group: @group)
      @motion = create(:motion, discussion: @discussion)
    end

    it "returns a count of motions" do
      expect(@discussion.reload.motions_count).to eq 1
    end

    it "updates correctly after creating a motion" do
      expect {
        @discussion.motions.create(attributes_for(:motion).merge({ author: @user }))
      }.to change { @discussion.reload.motions_count }.by(1)
    end

    it "updates correctly after deleting a motion" do
      expect {
        @motion.destroy
      }.to change { @discussion.reload.motions_count }.by(-1)
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
      @user1, @user2, @user3, @user4, @user_left_group =
        create(:user), create(:user), create(:user), create(:user), create(:user)
      @discussion = create :discussion, author: @user1
      @group = @discussion.group
      @group.add_member! @user2
      @group.add_member! @user3
      @group.add_member! @user4
      CommentService.create(comment: Comment.new(discussion: @discussion, body: 'hi'), actor: @user2)
      CommentService.create(comment: Comment.new(discussion: @discussion, body: 'hi'), actor: @user3)

      @group.add_member! @user_left_group
      CommentService.create(comment: Comment.new(discussion: @discussion, body: 'hi'), actor: @user_left_group)
      @group.membership_for(@user_left_group).destroy
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
      previous_motion = create(:motion, discussion: @discussion, author: previous_motion_author)
      MotionService.close(previous_motion)
      current_motion = create(:motion, discussion: @discussion, author: current_motion_author)

      @discussion.participants.should include(previous_motion_author)
      @discussion.participants.should include(current_motion_author)
    end

    it "should not include users who have not commented on discussion" do
      @discussion.participants.should_not include(@user4)
    end

    it "should not include users who have since left the group" do
      @discussion.participants.should_not include(@user_left_group)
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

  describe '#inherit_group_privacy' do
    # provides a default when the discussion is new
    # when present passes the value on unmodified
    let(:discussion) { Discussion.new }
    let(:group) { Group.new }

    subject { discussion.private }

    context "new discussion" do
      context "with group associated" do
        before do
          discussion.group = group
        end

        context "group is private only" do
          before do
            group.discussion_privacy_options = 'private_only'
            discussion.inherit_group_privacy!
          end
          it { should be true }
        end

        context "group is public or private" do
          before do
            group.discussion_privacy_options = 'public_or_private'
            discussion.inherit_group_privacy!
          end
          it { should be_nil }
        end

        context "group is public only" do
          before do
            group.discussion_privacy_options = 'public_only'
            discussion.inherit_group_privacy!
          end
          it { should be false }
        end
      end

      context "without group associated" do
        it { should be_nil }
      end
    end
  end

  describe "validator: privacy_is_permitted_by_group" do
    let(:discussion) { Discussion.new }
    let(:group) { Group.new }
    subject { discussion }


    context "discussion is public when group is private only" do
      before do
        group.discussion_privacy_options = 'private_only'
        discussion.group = group
        discussion.private = false
        discussion.valid?
      end
      it {should have(1).errors_on(:private)}
    end
  end

  describe "creating and destroying thread items" do
    let(:discussion) { create :discussion }

    describe "new discussion" do
      it "has the right values to begin with" do
        expect(discussion.items_count).to be 0
        expect(discussion.comments_count).to be 0
        expect(discussion.salient_items_count).to be 0
        expect(discussion.last_item_at).to be nil
        expect(discussion.last_comment_at).to be nil
        expect(discussion.last_activity_at).to eq discussion.created_at
        expect(discussion.first_sequence_id).to be 0
        expect(discussion.last_sequence_id).to be 0
      end
    end

    describe "create comment" do
      # ensure that items count and comments count are incremented
      # ensure that last_activity etc are all managed properly
      # last sequence too
      before do
        @comment = build(:comment, discussion: discussion)
        @event = CommentService.create(comment: @comment, actor: discussion.author)
        @event.reload
        @comment.reload
        discussion.reload
      end

      it "increments corrently" do
        expect(discussion.items_count).to be 1
        expect(discussion.comments_count).to be 1
        expect(discussion.salient_items_count).to be 1
        expect(discussion.last_item_at).to eq @comment.created_at
        expect(discussion.last_comment_at).to eq @comment.created_at
        expect(discussion.last_activity_at).to eq @comment.created_at
        expect(discussion.first_sequence_id).to be @event.sequence_id
        expect(discussion.last_sequence_id).to be @event.sequence_id
      end
    end

    describe "delete only comment" do
      before do
        @comment = build(:comment, discussion: discussion)
        @event = CommentService.create(comment: @comment, actor: discussion.author)
        @event.reload
        discussion.reload
        @comment.reload
        @comment.destroy
        discussion.reload
      end

      it "decrements correctly", focus: true do
        expect(discussion.items_count).to be 0
        expect(discussion.comments_count).to be 0
        expect(discussion.salient_items_count).to be 0
        expect(discussion.last_item_at).to eq nil
        expect(discussion.last_comment_at).to eq nil
        expect(discussion.last_activity_at).to eq discussion.created_at
        expect(discussion.last_sequence_id).to be 0
        expect(discussion.first_sequence_id).to be 0
        expect(discussion.last_sequence_id).to be 0
      end
    end

    describe "delete first comment of 2" do
      before do
        @comment1 = build(:comment, discussion: discussion)
        @event1 = CommentService.create(comment: @comment1, actor: discussion.author)

        @comment2 = build(:comment, discussion: discussion)
        @event2 = CommentService.create(comment: @comment2, actor: discussion.author)

        @event1.reload
        @event2.reload
        discussion.reload
        @comment1.reload
        @comment2.reload

        @comment1.destroy
        discussion.reload
      end

      it "decrements correctly" do
        expect(discussion.items_count).to be 1
        expect(discussion.comments_count).to be 1
        expect(discussion.salient_items_count).to be 1
        expect(discussion.last_item_at).to eq @comment2.created_at
        expect(discussion.last_comment_at).to eq @comment2.created_at
        expect(discussion.last_activity_at).to eq @comment2.created_at
        expect(discussion.first_sequence_id).to be @event2.sequence_id
        expect(discussion.last_sequence_id).to be @event2.sequence_id
      end
    end

    describe "delete last comment of 2" do
      before do
        @comment1 = build(:comment, discussion: discussion)
        @event1 = CommentService.create(comment: @comment1, actor: discussion.author)

        @comment2 = build(:comment, discussion: discussion)
        @event2 = CommentService.create(comment: @comment2, actor: discussion.author)

        @event1.reload
        @event2.reload
        discussion.reload
        @comment1.reload
        @comment2.reload

        @comment2.destroy
        discussion.reload
      end

      it "creates items correctly" do
        expect(@comment1.created_at).to eq @event1.created_at
        expect(@comment2.created_at).to eq @event2.created_at
      end

      it "decrements correctly" do
        expect(discussion.items_count).to be 1
        expect(discussion.comments_count).to be 1
        expect(discussion.salient_items_count).to be 1
        expect(discussion.last_item_at).to eq @comment1.created_at
        expect(discussion.last_comment_at).to eq @comment1.created_at
        expect(discussion.last_activity_at).to eq @comment1.created_at
        expect(discussion.first_sequence_id).to be @event1.sequence_id
        expect(discussion.last_sequence_id).to be @event1.sequence_id
      end
    end

    it "does not increment when creating a non thread-kind item" do
      stub_const("Discussion::THREAD_ITEM_KINDS", ['new_motion', 'new_discussion']) # not new_comment
      old_items_count = discussion.items_count
      CommentService.create(comment: build(:comment, discussion: discussion), actor: discussion.author)
      expect(discussion.reload.items_count).to eq old_items_count
    end
  end
end
