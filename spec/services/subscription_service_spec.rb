require 'rails_helper'
describe SubscriptionService do
  let (:response_subscription) { {
    id: group.subscription.chargify_subscription_id,
    activated_at: Time.zone.now.to_date,
    expires_at: (30.minutes.from_now.to_date),
    product: { handle: 'test-product' },
    canceled_at: 1.day.ago.to_date
  }.with_indifferent_access }
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:subscription) { group.subscription }
  let(:service) { SubscriptionService.new(group, user) }
  let(:chargify_service) { ChargifyService.new(1234) }

  before do
    group.admins << user
    group.subscription.update chargify_subscription_id: 1234
  end

  describe 'start_gift!' do
    it 'updates the group subscription' do
      SubscriptionService.new(group, user).start_gift!
      group.subscription.reload
      expect(group.subscription.kind).to eq 'gift'
      expect(group.subscription.trial_ended_at).to eq Time.zone.now.to_date
      expect(group.subscription.activated_at).to eq Time.zone.now.to_date
      expect(group.subscription.expires_at).to be_blank
      expect(group.subscription.plan).to be_blank
      expect(group.subscription.chargify_subscription_id).to be_blank
    end

    it 'updates the group subscription for a group without a subscription' do
      group.update(subscription: nil)
      SubscriptionService.new(group, user).start_gift!
      expect(group.reload.subscription.kind).to eq 'gift'
    end
  end

  describe 'start_subscription!' do

    before do
      chargify_service.stub(:fetch!).and_return(response_subscription)
      ChargifyService.stub(:new).and_return(chargify_service)
    end

    it 'updates the group subscription' do
      subscription.update kind: :trial
      service.start_subscription! 4321
      subscription.reload
      expect(subscription.trial_ended_at).to eq response_subscription[:activated_at]
      expect(subscription.activated_at).to eq response_subscription[:activated_at]
      expect(subscription.expires_at).to eq response_subscription[:expires_at]
      expect(subscription.plan).to eq response_subscription[:product][:handle]
      expect(subscription.chargify_subscription_id).to eq response_subscription[:id]
    end

    it 'does not set the trial ended at date if the group was not in trial mode' do
      subscription.update kind: :gift, trial_ended_at: nil
      service.start_subscription! 4321
      expect(subscription.reload.trial_ended_at).to_not eq response_subscription[:activated_at]
    end
  end

  describe 'change_plan!' do
    it 'updates the group subscription' do
    end
  end

  describe 'end_subscription!' do
    it 'shifts the group into gift mode' do
      subscription.update kind: :paid
      service.start_subscription! 4321
      subscription.reload
      service.end_subscription!
      expect(subscription.kind).to eq 'gift'
    end
  end
end
