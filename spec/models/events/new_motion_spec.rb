require 'rails_helper'

describe Events::NewMotion do
  let(:discussion) { create :discussion }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:motion) { create :motion, discussion: discussion }

  describe "::publish!" do

    it 'creates an event' do
      expect { Events::NewMotion.publish!(motion) }.to change { Event.count(kind: 'new_motion') }.by(1)
    end

    it 'returns an event' do
      expect(Events::NewMotion.publish!(motion)).to be_a Event
    end
  end

  describe 'channel_object' do
    it 'uses its group as the channel to publish to' do
      expect(Events::NewMotion.publish!(motion).send(:channel_object)).to eq discussion.group
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

    it 'does not call publish with the eventable''s parent group when not visible to parent members' do
      parent = @event.eventable.group.parent = create(:group)
      webhook = create :webhook, hookable: parent
      expect(WebhookService).not_to receive(:publish!).with({ event: @event, webhook: webhook })
      @event.reload.send(:notify_webhooks!)
    end
  end
end
