require 'rails_helper'

describe WebhookService do
  let(:user) { create(:user) }
  let(:discussion) { create :discussion }
  let(:comment) { build(:comment, discussion: discussion, author: user) }
  let(:motion) { build(:motion, discussion: discussion, author: user) }
  let(:vote) { build(:vote, motion: motion, author: user) }
  let(:webhook) { create :webhook, discussion: discussion, event_types: ['new_comment']}

  before do
    discussion.group.add_member!(user)
  end

  describe '#publish' do
    before do
      webhook
    end

    it 'should publish an event within its event kinds' do
      expect(RestClient).to receive(:post)
      CommentService.create actor: user, comment: comment
    end

    it 'should not publish an event outside of its event kinds' do
      expect(RestClient).to_not receive(:post)
      MotionService.create actor: user, motion: motion
    end

  end

  describe '#payload_for' do
    it 'serializes a new comment' do
      event = CommentService.create actor: user, comment: comment
      payload = JSON.parse WebhookService.send(:payload_for, webhook, event)
      expect(payload['username']).to eq user.name
      expect(payload['text']).to eq comment.body
    end

    it 'serializes a new motion' do
      event = MotionService.create actor: user, motion: motion
      payload = JSON.parse WebhookService.send(:payload_for, webhook, event)
      expect(payload['username']).to eq user.name
      expect(payload['text']).to match /#{motion.name}/
    end

    it 'serializes a new vote' do
      motion.save
      event = VoteService.create actor: user, vote: vote
      payload = JSON.parse WebhookService.send(:payload_for, webhook, event)
      expect(payload['username']).to eq user.name
      expect(payload['text']).to match /#{vote.statement}/
    end
  end

  describe '#serializer_for' do
    it 'should serialize based on the webhook''s kind' do
      webhook.kind = :slack
      expect(WebhookService.send(:serializer_for, webhook)).to eq Webhooks::SlackSerializer
    end
  end

end
