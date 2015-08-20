require 'rails_helper'

describe Events::NewMotion do
  let(:discussion) { create :discussion }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:motion) { create :motion, discussion: discussion }

  describe "::publish!" do
    let(:event) { double(:event, notify_users!: true, eventable: motion, id: 1) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_motion',
                                          eventable: motion,
                                          discussion: motion.discussion)
      Events::NewMotion.publish!(motion)
    end

    it 'marks the discussion reader as participating' do
      Events::NewMotion.publish!(motion)
      expect(DiscussionReader.for(user: motion.author, discussion: discussion).participating).to be_truthy
    end

    it 'returns an event' do
      expect(Events::NewMotion.publish!(motion)).to eq event
    end
  end

  describe 'notify_webhooks!' do

    let(:motion) { build(:motion) }

    before do
      @event = Events::NewMotion.publish! motion
    end

    it 'calls publish on the eventable' do
      webhook = create :webhook, hookable: @event.eventable.discussion
      expect(WebhookService).to receive(:publish!).with({ event: @event, webhook: webhook })
      @event.reload.send(:notify_webhooks!)
    end

    it 'calls publish with the eventable''s group' do
      webhook = create :webhook, hookable: @event.eventable.group
      expect(WebhookService).to receive(:publish!).with({ event: @event, webhook: webhook })
      @event.reload.send(:notify_webhooks!)
    end

    it 'calls publish with the eventable''s parent group' do
      parent = @event.eventable.group.parent = create(:group)
      @event.eventable.group.update is_visible_to_parent_members: true
      webhook = create :webhook, hookable: parent
      expect(WebhookService).to receive(:publish!).with({ event: @event, webhook: webhook })
      @event.reload.send(:notify_webhooks!)
    end

    it 'calls publish with the eventable''s parent group' do
      parent = @event.eventable.group.parent = create(:group)
      webhook = create :webhook, hookable: parent
      expect(WebhookService).not_to receive(:publish!).with({ event: @event, webhook: webhook })
      @event.reload.send(:notify_webhooks!)
    end
  end
end
