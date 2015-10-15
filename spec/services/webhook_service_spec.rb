require 'rails_helper'

describe WebhookService do
  let(:user) { create(:user) }
  let(:discussion) { create :discussion }
  let(:comment) { build(:comment, discussion: discussion, author: user) }
  let(:motion) { build(:motion, discussion: discussion, author: user) }
  let(:vote) { build(:vote, motion: motion, author: user) }
  let(:webhook) { create :webhook, hookable: discussion, event_types: ['new_motion', 'new_vote']}

  before do
    discussion.group.add_member!(user)
  end

  describe '#publish' do
    before do
      webhook
    end

    it 'should publish an event within its event kinds' do
      expect(HTTParty).to receive(:post)
      MotionService.create actor: user, motion: motion
    end

    it 'should not publish an event outside of its event kinds' do
      expect(HTTParty).to_not receive(:post)
      MotionService.create_outcome actor: user, motion: motion, params: { outcome: 'outcome' }
    end

    it 'should not publish an event or error for events which do not have serializers' do
      expect(HTTParty).to_not receive(:post)
      CommentService.create comment: comment, actor: user
    end

  end

  describe '#payload_for' do

    it 'serializes a new motion' do
      event = MotionService.create actor: user, motion: motion
      payload = JSON.parse WebhookService.send(:payload_for, webhook, event)
      expect(payload['username']).to eq 'Loomio Bot'
      expect(payload['text']).to match /#{user.name}.* started a new proposal in .*#{discussion.title}/
    end

    it 'serializes a motion outcome created' do
      motion.save
      event = MotionService.create_outcome actor: user, motion: motion, params: { outcome: 'new outcome' }
      payload = JSON.parse WebhookService.send(:payload_for, webhook, event)
      expect(payload['username']).to eq 'Loomio Bot'
      expect(payload['text']).to match /#{user.name}.*published an outcome in.*#{motion.name}/
    end

    it 'serializes a motion outcome updated' do
      motion.save
      event = MotionService.update_outcome actor: user, motion: motion, params: { outcome: 'updated outcome' }
      payload = JSON.parse WebhookService.send(:payload_for, webhook, event)
      expect(payload['username']).to eq 'Loomio Bot'
      expect(payload['text']).to match /#{user.name}.*updated the outcome for.*#{motion.name}/
    end

    it 'serializes a new vote' do 
      event = VoteService.create actor: user, vote: vote
      payload = JSON.parse WebhookService.send(:payload_for, webhook, event)
      expect(payload['username']).to eq 'Loomio Bot'
      vote_position = I18n.t :"webhooks.slack.position_verbs.#{vote.position}"
      expect(payload['text']).to match /#{user.name}.* .*#{vote_position}.* .*#{vote.proposal.name}.* in .*#{discussion.title}/
    end
  end

  describe '#webhook_object_for' do
    it 'should create a struct based on the event\'s kind' do
      event = MotionService.create_outcome actor: user, motion: motion, params: { outcome: 'new outcome' }
      webhook_event = WebhookService.send(:webhook_object_for, webhook, event)
      expect(webhook_event).to be_a Webhooks::Slack::MotionOutcomeCreated
    end
  end

end
