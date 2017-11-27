require 'rails_helper'

describe Events::NewComment do
  let(:discussion) { create :discussion }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:comment) { create :comment, discussion: discussion, author: user }
  let(:reply) { create :comment, discussion: discussion, parent: comment, author: user }

  describe "::publish!" do

    it 'creates an event' do
      expect { Events::NewComment.publish!(comment) }.to change { Event.where(kind: 'new_comment').count }.by(1)
    end

    it 'associates parent event if comment is reply' do
      parent_event = Events::NewComment.publish!(comment)
      child_event = Events::NewComment.publish!(reply)
      expect(child_event.parent_id).to eq parent_event.id
    end

    it 'returns an event' do
      expect(Events::NewComment.publish!(comment).class).to eq Events::NewComment
    end
  end
end
