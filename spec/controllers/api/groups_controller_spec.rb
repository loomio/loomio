require 'rails_helper'
describe API::GroupsController do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:domain_group) { create :group, subdomain: 'giveitago' }
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

  describe 'for_subdomain' do
    it 'returns a group with the given subdomain when it exists' do
      domain_group
      get :for_subdomain, subdomain: 'giveitago', format: :json
      json = JSON.parse(response.body)
      ids = json['groups'].map { |v| v['id'] }
      expect(ids).to include domain_group.id
      expect(ids).to_not include group.id
    end

    it 'returns an empty array when the subdomain doesn\'t exist' do
      domain_group
      get :for_subdomain, subdomain: 'notadomain', format: :json
      json = JSON.parse(response.body)
      ids = json['groups'].map { |v| v['id'] }
      expect(ids).to_not include domain_group.id
      expect(ids).to_not include group.id
    end
  end

end
