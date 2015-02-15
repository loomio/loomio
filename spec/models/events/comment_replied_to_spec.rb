require 'rails_helper'

describe Events::CommentRepliedTo do
  let(:discussion) { create :discussion }
  let(:other) { create :user }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:parent) { create :comment, discussion: discussion, author: other }
  let(:comment) { create :comment, discussion: discussion, author: user, parent: parent }

  describe "::publish!" do
    let(:event) { double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event); comment }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'comment_replied_to',
                                          eventable: comment,
                                          user: comment.author,
                                          created_at: comment.created_at)
      Events::CommentRepliedTo.publish!(comment)
    end

    it 'returns an event' do
      expect(Events::CommentRepliedTo.publish!(comment)).to eq event
    end
  end
end
