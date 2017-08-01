require 'rails_helper'

describe "Discussions and Discussion Items Working together as one beautiful ecosystem" do
  describe "situations designed to ensure this works well" do
    # this is the first/main method we call to delete a comment
    # after it has been called
    # discussion.items_count should be 1 less
    # discussion.comments_count should be 1 less
    # discussion.first_sequence_id should be correct
    # discussion.last_sequence_id should be correct
    # discussion.last_comment_at should be reset
    # discussion.last_activity_at should be reset
    # all discussion readers should be reset according to their last_read_at.

    describe "discussion with 2 comments, then first comment is deleted" do
      let(:user) { FactoryGirl.create(:user) }
      let(:commentor){ FactoryGirl.create(:user) }
      let(:discussion) { FactoryGirl.build(:discussion) }
      let(:group) { FactoryGirl.create(:formal_group) }
      let(:first_comment) { FactoryGirl.build(:comment, discussion: discussion) }
      let(:second_comment) { FactoryGirl.build(:comment, discussion: discussion) }

      before do
        group.add_member!(commentor)
        group.add_member!(user)
        discussion.group = group
        DiscussionService.create(discussion: discussion, actor: commentor)
      end

      def create_first_comment
        CommentService.create(comment: first_comment, actor: commentor)
      end

      def create_second_comment
        CommentService.create(comment: second_comment, actor: commentor)
      end

      def delete_first_comment
        CommentService.destroy(comment: first_comment, actor: commentor)
      end

      def view_discussion
        discussion_reader.viewed!(discussion_reader.discussion.last_activity_at)
      end

      def discussion_reader
        dr = DiscussionReader.for(user: user, discussion: discussion)
        dr.save
        dr
      end

      def reload_everything
        discussion.reload
        discussion_reader.reload
      end

      it "user has seen nothing" do
        create_first_comment
        create_second_comment
        delete_first_comment
        reload_everything
        expect(discussion.salient_items_count -
               discussion_reader.read_salient_items_count).to eq 1
      end

      it "user sees discussion before the comments" do
        view_discussion
        create_first_comment
        create_second_comment
        delete_first_comment
        reload_everything
        expect(discussion.salient_items_count -
               discussion_reader.read_salient_items_count).to eq 1
      end

      it "user sees discussion before second comment" do
        create_first_comment
        view_discussion
        create_second_comment
        delete_first_comment
        reload_everything
        expect(discussion.salient_items_count -
               discussion_reader.read_salient_items_count).to eq 1
      end
    end
  end
end
