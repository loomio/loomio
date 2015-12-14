require 'rails_helper'

describe Events::NewComment do
  let(:discussion) { create :discussion }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:comment) { create :comment, discussion: discussion, author: user }

  describe "::publish!" do

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_comment',
                                          eventable: comment,
                                          discussion: comment.discussion,
                                          created_at: comment.created_at)
      Events::NewComment.publish!(comment)
    end

    it 'returns an event' do
      expect(Events::NewComment.publish!(comment).class).to eq Events::NewComment
    end

    it 'uses its group as the channel to publish to' do
      expect(Events::NewComment.publish!(comment).send(:channel_object)).to eq discussion.group
    end
  end
end
