require 'rails_helper'

describe Discussion do
  let(:user)       { create :user }
  let(:group)      { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:motion)     { create :motion, discussion: discussion }

  context "versioning" do
    before do
      @discussion = create :discussion
      @version_count = @discussion.versions.count
      PaperTrail.enabled = true
    end

    # it "doesn't create a new version when unrelevant attribute is edited" do
    #   @discussion.update_attribute :author, create(:user)
    #   @discussion.should have(@version_count).versions
    # end

    it "creates a new version when discussion.description is edited" do
      @discussion.update_attribute :description, "new description"
      @discussion.should have(@version_count + 1).versions
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
      it "should have(1).errors_on(:private)" do
        expect(discussion.errors.to_a).to include "Private must be private"
      end
    end
  end

  describe "creating and destroying thread items" do
    let(:discussion) { create :discussion }

    describe "new discussion" do
      it "has the right values to begin with" do
        expect(discussion.items_count).to be 0
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
        expect(discussion.last_activity_at).to eq @event.eventable.created_at
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
        discussion.update_sequence_info!
        discussion.reload
      end

      it "decrements correctly" do
        expect(discussion.items_count).to be 0
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
        expect(discussion.last_activity_at).to eq @event2.eventable.created_at
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
        discussion.update_sequence_info!
        discussion.reload
      end

      it "decrements correctly" do
        expect(discussion.items_count).to be 1
        expect(discussion.last_activity_at).to eq @event1.eventable.created_at
        expect(discussion.first_sequence_id).to be @event1.sequence_id
        expect(discussion.last_sequence_id).to be @event1.sequence_id
      end
    end
  end

  describe 'mentioning' do
    let(:discussion) { build(:discussion, description: "Hello @#{user.username}!", description_format: 'md') }
    let(:another_user) { create(:user) }

    describe '#mentionable_text' do
      it 'stores the description as mentionable text' do
        expect(discussion.send(:mentionable_text)).to eq discussion.description
      end
    end

    describe 'mentionable_usernames' do
      it 'can extract usernames' do
        expect(discussion.mentioned_usernames).to include user.username
      end

      it 'does not duplicate usernames' do
        discussion.description += " Goodbye @#{user.username}!"
        expect(discussion.mentioned_usernames).to eq [user.username]
      end

      it 'does not extract the authors username' do
        discussion.description = "Hello @#{discussion.author.username}!"
        expect(discussion.mentioned_usernames).to_not include discussion.author.username
      end
    end
  end
end
