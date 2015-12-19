require 'rails_helper'

describe Events::NewComment do
  let(:discussion) { create :discussion }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:comment) { create :comment, discussion: discussion, author: user }

  describe "::publish!" do

    it 'creates an event' do
      expect { Events::NewComment.publish!(comment) }.to change { Event.count(kind: 'new_comment') }.by(1)
    end

    it 'returns an event' do
      expect(Events::NewComment.publish!(comment).class).to eq Events::NewComment
    end

    it 'uses its group as the channel to publish to' do
      expect(Events::NewComment.publish!(comment).send(:channel_object)).to eq discussion.group
    end
  end
end
