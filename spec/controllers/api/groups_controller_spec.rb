require 'rails_helper'
describe API::GroupsController do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }

  before do
    group.admins << user
    sign_in user
  end

  describe 'show' do
    it 'returns the group json' do
      discussion
      get :show, id: group.key, format: :json
      json = JSON.parse(response.body)
      expect(json.keys).to include *(%w[groups])
      expect(json['groups'][0].keys).to include *(%w[
        id
        key
        name
        description
        parent_id
        created_at
        members_can_edit_comments
        members_can_raise_proposals
        members_can_vote])
    end
  end

  describe 'use_gift_subscription' do
    it 'creates a gift subscription for the group' do
      post :use_gift_subscription, id: group.key
      group_json = JSON.parse(response.body)['groups'][0]
      expect(group_json['subscription_kind']).to eq 'gift'
    end

    it 'does not set a gift subscription unless chargify is set up' do
      SubscriptionService.stub(:available?).and_return(false)
      post :use_gift_subscription, id: group.key
      expect(response.status).to eq 400
      expect(group.subscription.reload.kind).to_not eq 'gift'
    end
  end

end
