require 'spec_helper'

describe Queries::UnreadDiscussions do
  let(:viewer) { create :user }
  let(:commenter) { create :user }
  let(:group) { create :group }
  let(:discussion) { create(:discussion, group: group) }

  describe ".for(user, group)" do
    before do
      group.add_member! commenter
    end
    context "discussion has not been viewed" do
      it "returns discussion" do
        Queries::UnreadDiscussions.for(viewer, group).should include(discussion)
      end
    end

    context "discussion has been viewed" do
      it "does not return discussion" do
        ViewLogger.discussion_viewed(discussion, viewer)
        Queries::UnreadDiscussions.for(viewer, group).should_not include(discussion)
      end
    end

    context "discussion has been viewed but there is a new comment" do
      it "returns discussion" do
        ViewLogger.discussion_viewed(discussion, viewer)
        discussion.add_comment(commenter, "hi", false)
        Queries::UnreadDiscussions.for(viewer, group).should include(discussion)
      end
    end

    context 'discussion has been unfollowed' do
      it 'does not return discussion' do
        ViewLogger.discussion_unfollowed(discussion, viewer)
        discussion.add_comment(commenter, "hi", false)
        Queries::UnreadDiscussions.for(viewer, group).should_not include(discussion)
      end
    end
  end
end
