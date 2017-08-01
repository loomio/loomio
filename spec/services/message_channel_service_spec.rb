require 'rails_helper'

describe MessageChannelService do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :formal_group }
  let(:another_group) { create :formal_group }
  let(:discussion) { create :discussion, group: group }
  let(:another_discussion) { create :discussion, group: another_group}
  let(:motion) { create :motion, discussion: discussion }
  let(:data) {{ data: 'data' }}

  before do
    group.members << user
  end

  describe 'subscribe_to' do
    it 'allows users to subscribe to themselves' do
      expect(Rails.application.secrets).to receive(:faye_url).and_return('fayeurl').at_least(:once)
      expect(PrivatePub).to receive(:subscription).with(channel: "/user-#{user.key}", server: Rails.application.secrets.faye_url)
      MessageChannelService.subscribe_to(user: user, model: user)
    end

    it 'allows users to subscribe to a group' do
      expect(Rails.application.secrets).to receive(:faye_url).and_return('fayeurl').at_least(:once)
      expect(PrivatePub).to receive(:subscription).with(channel: "/group-#{group.key}", server: Rails.application.secrets.faye_url)
      MessageChannelService.subscribe_to(user: user, model: group)
    end

    it 'allows users to subscribe to a discussion' do
      expect(Rails.application.secrets).to receive(:faye_url).and_return('fayeurl').at_least(:once)
      expect(PrivatePub).to receive(:subscription).with(channel: "/discussion-#{discussion.key}", server: Rails.application.secrets.faye_url)
      MessageChannelService.subscribe_to(user: user, model: discussion)
    end

    it 'subscribes users to the global channel' do
      expect(Rails.application.secrets).to receive(:faye_url).and_return('fayeurl').at_least(:once)
      expect(PrivatePub).to receive(:subscription).with(channel: "/global", server: Rails.application.secrets.faye_url)
      MessageChannelService.subscribe_to(user: user, model: GlobalMessageChannel.instance)
    end

    it 'does not allow users to subscribe to things they cant see' do
      expect(Rails.application.secrets).to receive(:faye_url).and_return('fayeurl').at_least(:once)
      expect { MessageChannelService.subscribe_to(user: user, model: another_user) }.to raise_error { MessageChannelService::AccessDeniedError }
      expect { MessageChannelService.subscribe_to(user: user, model: another_group) }.to raise_error { MessageChannelService::AccessDeniedError }
      expect { MessageChannelService.subscribe_to(user: user, model: another_discussion) }.to raise_error { MessageChannelService::AccessDeniedError }
    end

    it 'does not allow users to subscribe to models without a channel' do
      expect { MessageChannelService.subscribe_to(user: user, model: motion) }.to raise_error { MessageChannelService::UnknownChannelError }
    end
  end

  describe 'publish' do

    it 'publishes data to a user model' do
      expect(Rails.application.secrets).to receive(:faye_url).and_return('fayeurl')
      expect(PrivatePub).to receive(:publish_to).with("/user-#{user.key}", data)
      MessageChannelService.publish(data, to: user)
    end

    it 'publishes data to a discussion model' do
      expect(Rails.application.secrets).to receive(:faye_url).and_return('fayeurl')
      expect(PrivatePub).to receive(:publish_to).with("/discussion-#{discussion.key}", data)
      MessageChannelService.publish(data, to: discussion)
    end

    it 'publishes data to a group model' do
      expect(Rails.application.secrets).to receive(:faye_url).and_return('fayeurl')
      expect(PrivatePub).to receive(:publish_to).with("/group-#{group.key}", data)
      MessageChannelService.publish(data, to: group)
    end

    it 'publishes data to the global channel' do
      expect(Rails.application.secrets).to receive(:faye_url).and_return('fayeurl')
      expect(PrivatePub).to receive(:publish_to).with("/global", data)
      MessageChannelService.publish(data, to: GlobalMessageChannel.instance)
    end

    it 'does not publish data to an invalid model' do
      expect(PrivatePub).not_to receive(:publish_to)
      expect { MessageChannelService.publish(data, to: motion) }.to raise_error { MessageChannelService::UnknownChannelError }
    end
  end
end
