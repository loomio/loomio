require 'rails_helper'

describe Events::NewComment do
  let(:discussion) { create :discussion }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:comment) { create :comment, discussion: discussion, author: user }

  describe "::publish!" do

    it 'creates an event' do
      expect { Events::NewComment.publish!(comment) }.to change { Event.where(kind: 'new_comment').count }.by(1)
    end

    it 'returns an event' do
      expect(Events::NewComment.publish!(comment).class).to eq Events::NewComment
    end
  end
end
