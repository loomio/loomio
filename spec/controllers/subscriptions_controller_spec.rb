require 'rails_helper'

describe SubscriptionsController do

  let(:group) { create :group }
  let(:subscription) { group.subscription }
  let(:subscription_params) { {
    subscription: {
      id: subscription.id,
      product: {},
      customer: { reference: "#{group.id}-#{Time.now.to_i}" }
    }
  }.with_indifferent_access }

  describe 'select_gift_plan' do
    it 'puts groups onto free plan'  do

      post :select_gift_plan, group_key: group.key
      expect(group.subscription.reload.kind).to eq 'gift'
    end

    it 'unless group is paying'  do
      group.subscription.update kind:                     :paid,
                                payment_method:           :chargify,
                                activated_at:             Time.now,
                                expires_at:               Time.now,
                                plan:                     'standard',
                                chargify_subscription_id: 1

      post :select_gift_plan, group_key: group.key
      expect(group.subscription.reload.kind).to eq 'paid'
    end
  end

  describe 'webhook' do
    it 'performs a signup_success' do
      post :webhook, payload: subscription_params, event: :signup_success
      expect(subscription.reload.kind).to eq 'paid'
      expect(response.status).to eq 200
    end

    it 'performs a subscription_product_change' do
      subscription_params[:subscription][:product][:handle] = 'test-handle'
      post :webhook, payload: subscription_params, event: :subscription_product_change
      expect(subscription.reload.plan).to eq 'test-handle'
      expect(response.status).to eq 200
    end

    it 'performs a subscription_state_change' do
      subscription_params[:subscription][:state] = 'canceled'
      subscription.update kind: :paid
      post :webhook, payload: subscription_params, event: :subscription_state_change
      expect(subscription.reload.kind).to eq 'gift'
      expect(response.status).to eq 200
    end

    it 'responds with bad request if chargify is not set up in-app' do
      SubscriptionService.stub(:available?).and_return(false)
      post :webhook, event: :signup_success
      expect(response.status).to eq 400
    end
  end

end
