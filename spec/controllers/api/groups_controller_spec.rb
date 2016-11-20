require 'rails_helper'
describe API::GroupsController do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:subgroup) { create :group, parent: group }
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
        members_can_raise_motions
        members_can_vote])
    end

    it 'returns the parent group information' do
      get :show, id: subgroup.key, format: :json
      json = JSON.parse(response.body)
      group_ids = json['groups'].map { |g| g['id'] }
      expect(group_ids).to include subgroup.id
      expect(group_ids).to include group.id
    end

    context 'logged out' do
      before { @controller.stub(:current_user).and_return(LoggedOutUser.new) }
      let(:private_group) { create(:group, is_visible_to_public: false) }

      it 'returns public groups if the user is logged out' do
        get :show, id: group.key, format: :json
        json = JSON.parse(response.body)
        group_ids = json['groups'].map { |g| g['id'] }
        expect(group_ids).to include group.id
      end

      it 'returns unauthorized if the user is logged out and the group is private' do
        get :show, id: private_group.key, format: :json
        expect(response.status).to eq 403
      end
    end

  end

  describe 'update' do
    it 'can update the group privacy to "open"' do
      group.update(group_privacy: 'closed')
      group_params = { group_privacy: 'open' }
      post :update, id: group.key, group: group_params
      group.reload
      expect(group.group_privacy).to eq 'open'
      expect(group.is_visible_to_public).to eq true
      expect(group.membership_granted_upon).to eq 'approval'
      expect(group.discussion_privacy_options).to eq 'public_only'
    end

    it 'can update the group privacy to "open" join on request' do
      group.update(group_privacy: 'closed', membership_granted_upon: 'approval')
      group_params = { group_privacy: 'open', membership_granted_upon: 'request' }
      post :update, id: group.key, group: group_params
      group.reload
      expect(group.group_privacy).to eq 'open'
      expect(group.is_visible_to_public).to eq true
      expect(group.membership_granted_upon).to eq 'request'
      expect(group.discussion_privacy_options).to eq 'public_only'
    end

    it 'can update the group privacy to "closed"' do
      group_params = { group_privacy: 'closed' }
      post :update, id: group.key, group: group_params
      group.reload
      expect(group.group_privacy).to eq 'closed'
      expect(group.is_visible_to_public).to eq true
      expect(group.membership_granted_upon).to eq 'approval'
    end

    it 'can update the group privacy to "secret"' do
      group_params = { group_privacy: 'secret' }
      post :update, id: group.key, group: group_params
      group.reload
      expect(group.group_privacy).to eq 'secret'
      expect(group.is_visible_to_public).to eq false
      expect(group.membership_granted_upon).to eq 'invitation'
      expect(group.discussion_privacy_options).to eq 'private_only'
    end
  end

  describe 'count_explore_results' do
    it 'returns the number of explore group results matching the search term' do
      group.update_attribute(:name, 'exploration team')
      explore_group = create(:group, name: 'investigation team')
      second_explore_group = create(:group, name: 'inspection group')
      get :count_explore_results, { q: 'team' }
      expect(JSON.parse(response.body)['count']).to eq 2
    end
  end

end
