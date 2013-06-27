require 'spec_helper'

describe Queries::VisibleDiscussions do
  let(:viewer) { create :user }
  let(:commenter) { create :user }
  let(:group) { create :group }
  let(:discussion) { create(:discussion, group: group) }

  before do
    group.add_member! commenter
    group.add_member! viewer
    discussion
  end

  context 'a read discussion' do
    before { DiscussionReader.for(discussion, viewer).viewed! }

    subject do
      Queries::VisibleDiscussions.new(user: viewer, group: group).first
    end

    it 'includes read_comments_count of 0', focus: true do
      subject[:read_comments_count].to_i.should == 0
    end

    context 'with a read comment' do
      before do
        discussion.add_comment(commenter, 'hi')
        DiscussionReader.for(discussion, viewer).viewed!
      end

      it 'includes read_comments_count of 1' do
        subject[:read_comments_count].to_i.should == 1
      end
    end
  end

  context 'showing unread discussions only' do
    subject do
      Queries::VisibleDiscussions.new(user: viewer, group: group).unread.followed
    end

    context 'an unread discussion exists' do
      it {should include discussion }
    end

    context "a read discussion exists" do
      before { DiscussionReader.for(discussion, viewer).viewed! }

      it {should_not include discussion }

      context 'with an unread comment' do
        before { discussion.add_comment(commenter, "hi") }

        it {should include discussion}
      end
    end

    context 'muted unread discussion exist' do
      before do
        DiscussionReader.for(discussion, viewer).unfollow!
        discussion.add_comment(commenter, "hi")
      end

      it {should_not include discussion }
    end
  end
end
