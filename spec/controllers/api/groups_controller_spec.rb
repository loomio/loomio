require 'rails_helper'
describe API::GroupsController do

  let(:user) { create :user }
  let(:group) { create :group, creator: user, is_visible_to_public: false }
  let(:subgroup) { create :group, parent: group, is_visible_to_public: false, is_visible_to_parent_members: true }
  let(:subgroup_hidden) { create :group, parent: group, is_visible_to_public: false, is_visible_to_parent_members: false }
  let(:discussion) { create :discussion, group: group }
  let(:guest_discussion) { create :discussion, group: guest_discussion_group}
  let(:guest_discussion_group) { create :group, is_visible_to_public: false }
  let(:another_discussion) { create :discussion, group: another_group }
  let(:another_group) { create :group, is_visible_to_public: false }
  let(:public_group) { create :group, is_visible_to_public: true }

  before do
    group.add_admin! user
    DiscussionReader.create!(discussion_id: guest_discussion.id,
                             user_id: user.id,
                             inviter_id: guest_discussion.author_id)
  end

  describe 'index' do
    before do
      another_discussion
      sign_in user
    end

    it 'returns groups by xids' do
      # test discusison guest group fetch..
      get :index, params: { xids: [group, subgroup, another_group, public_group, guest_discussion.group, another_discussion.group].map(&:id).join('x') }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['groups'].map{|h| h['id']}).to include group.id, public_group.id, subgroup.id, guest_discussion.group_id
      expect(json['groups'].map{|h| h['id']}).not_to include another_group.id, subgroup_hidden.id, another_discussion.group_id
    end
  end

  describe 'export' do
    before do
      sign_in user
    end

    it 'gives access denied if you dont belong' do
      post :export, params: { id: another_group.key }
      expect(response.status).to eq 403
    end

    it 'sends an email' do
      expect { post :export, params: { id: group.key } }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "destroy" do
    context "signed in" do
      before do
        sign_in user
      end
      it 'destroys my group' do
        delete :destroy, params: { id: group.id }
        expect(response.status).to eq 200
        expect { group.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'does not destroy another group' do
        delete :destroy, params: { id: another_group.id }
        expect(response.status).to eq 403
      end
    end

    context "not signed in" do
      it 'returns 403' do
        delete :destroy, params: { id: group.id }
        expect(response.status).to eq 403
      end
    end
  end

  describe 'suggest_handle' do
    before do
      sign_in user
    end
    it 'suggests a handle based on a group name' do
      get :suggest_handle, params: {name: "test case"}
      json = JSON.parse(response.body)
      expect(json['handle']).to eq 'test-case'
    end

    it 'ensures suggestions are not already taken' do
      create :group, handle: 'test-case'
      get :suggest_handle, params: {name: "test case"}
      json = JSON.parse(response.body)
      expect(json['handle']).to eq 'test-case-1'
    end

    it 'subgroup handle includes parent handle' do
      get :suggest_handle, params: {name: "test case", parent_handle: 'parent'}
      json = JSON.parse(response.body)
      expect(json['handle']).to eq 'parent-test-case'
    end
  end

  describe 'show' do
    context "signed in" do
      before do
        sign_in user
      end

      it 'returns the group json' do
        discussion
        get :show, params: { id: group.key }, format: :json
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
          members_can_raise_motions])
      end

      it 'returns the parent group information' do
        get :show, params: { id: subgroup.key }, format: :json
        json = JSON.parse(response.body)
        group_ids = json['groups'].map { |g| g['id'] }
        expect(group_ids).to include subgroup.id
        expect(group_ids).to include group.id
      end
    end

    context 'logged out' do
      let(:private_group) { create(:group, is_visible_to_public: false) }

      it 'returns public groups if the user is logged out' do
        get :show, params: { id: group.key }, format: :json
        json = JSON.parse(response.body)
        group_ids = json['groups'].map { |g| g['id'] }
        expect(group_ids).to include group.id
      end

      it 'returns unauthorized if the user is logged out and the group is private' do
        get :show, params: { id: private_group.key }, format: :json
        expect(response.status).to eq 403
      end

      it 'allows show with group token' do
        session[:pending_group_token] = private_group.token
        get :show, params: { id: private_group.key }, format: :json
        expect(response.status).to eq 200
      end

      it 'allows show with membership token' do
        new_user = create :user
        membership = private_group.memberships.create(user: new_user)
        session[:pending_membership_token] = membership.token
        get :show, params: { id: private_group.key }, format: :json
        expect(response.status).to eq 200
      end
    end
  end

  describe 'update' do
    before { sign_in user }

    it 'can update the group privacy to "open"' do
      group.update(group_privacy: 'closed')
      group_params = { group_privacy: 'open' }
      post :update, params: { id: group.key, group: group_params }
      group.reload
      expect(group.group_privacy).to eq 'open'
      expect(group.is_visible_to_public).to eq true
      expect(group.membership_granted_upon).to eq 'approval'
      expect(group.discussion_privacy_options).to eq 'public_only'
    end

    it 'can update the group privacy to "open" join on request' do
      group.update(group_privacy: 'closed', membership_granted_upon: 'approval')
      group_params = { group_privacy: 'open', membership_granted_upon: 'request' }
      post :update, params: { id: group.key, group: group_params }
      group.reload
      expect(group.group_privacy).to eq 'open'
      expect(group.is_visible_to_public).to eq true
      expect(group.membership_granted_upon).to eq 'request'
      expect(group.discussion_privacy_options).to eq 'public_only'
    end

    it 'can update the group privacy to "closed"' do
      group_params = { group_privacy: 'closed' }
      post :update, params: { id: group.key, group: group_params }
      group.reload
      expect(group.group_privacy).to eq 'closed'
      expect(group.is_visible_to_public).to eq true
      expect(group.membership_granted_upon).to eq 'approval'
    end

    it 'can update the group privacy to "secret"' do
      group_params = { group_privacy: 'secret' }
      post :update, params: { id: group.key, group: group_params }
      group.reload
      expect(group.group_privacy).to eq 'secret'
      expect(group.is_visible_to_public).to eq false
      expect(group.membership_granted_upon).to eq 'invitation'
      expect(group.discussion_privacy_options).to eq 'private_only'
    end
  end

  describe 'count_explore_results' do
    before { sign_in user }
    it 'returns the number of explore group results matching the search term' do
      group.update_attribute(:name, 'exploration team')
      group.update_attribute(:memberships_count, 5)
      group.update_attribute(:discussions_count, 3)
      group.subscription = Subscription.create(plan: 'trial', state: 'active')
      group.save
      second_explore_group = create(:group, name: 'inspection group')
      second_explore_group.update_attribute(:memberships_count, 5)
      second_explore_group.update_attribute(:discussions_count, 3)
      second_explore_group.subscription = Subscription.create(plan: 'trial', state: 'active')
      second_explore_group.save
      get :count_explore_results, params: { q: 'team' }
      expect(JSON.parse(response.body)['count']).to eq 1
    end
  end

end
