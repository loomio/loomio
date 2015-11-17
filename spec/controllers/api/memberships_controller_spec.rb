require 'rails_helper'
describe API::MembershipsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:user_named_biff) { create :user, name: "Biff Bones" }
  let(:user_named_bang) { create :user, name: "Bang Whamfist" }
  let(:alien_named_biff) { create :user, name: "Biff Beef", email: 'beef@biff.com' }
  let(:alien_named_bang) { create :user, name: 'Bang Beefthrong' }

  let(:group) { create :group }
  let(:another_group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:comment_params) {{
    body: 'Yo dawg those kittens be trippin for some dippin',
    discussion_id: discussion.id
  }}

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    group.users  << user_named_biff
    group.users  << user_named_bang
    another_group.users << user
    another_group.users << alien_named_bang
    another_group.users << alien_named_biff
    sign_in user
  end

  describe 'index' do
    context 'success' do
      it 'returns users filtered by group' do
        get :index, group_id: group.id, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users memberships groups])
        users = json['users'].map { |c| c['id'] }
        groups = json['groups'].map { |g| g['id'] }
        expect(users).to include user_named_biff.id
        expect(users).to_not include alien_named_biff.id
        expect(groups).to include group.id
      end

      it 'returns users ordered by name' do
        get :index, group_id: group.id, format: :json
        json = JSON.parse(response.body)
        usernames = json['users'].map { |c| c['name'] }
        expect(usernames.sort).to eq usernames
      end

      context 'logged out' do
        before { @controller.stub(:current_user).and_return(LoggedOutUser.new) }
        let(:private_group) { create(:group, is_visible_to_public: false) }

        it 'returns users filtered by group for a public group' do
          get :index, group_id: group.id, format: :json
          json = JSON.parse(response.body)
          expect(json.keys).to include *(%w[users memberships groups])
          users = json['users'].map { |c| c['id'] }
          groups = json['groups'].map { |g| g['id'] }
          expect(users).to include user_named_biff.id
          expect(users).to_not include alien_named_biff.id
          expect(groups).to include group.id
        end

        it 'responds with unauthorized for private groups' do
          get :index, group_id: private_group.id, format: :json
          expect(response.status).to eq 403
        end
      end
    end
  end

  describe 'for_user' do
    let(:public_group) { create :group, is_visible_to_public: true }
    let(:private_group) { create :group, is_visible_to_public: false }

    it 'returns visible groups for the given user' do
      public_group
      private_group.users << another_user
      group.users << another_user

      get :for_user, user_id: another_user.id
      json = JSON.parse(response.body)
      group_ids = json['groups'].map { |g| g['id'] }
      expect(group_ids).to include group.id
      expect(group_ids).to_not include public_group.id
      expect(group_ids).to_not include private_group.id
    end
  end

  describe 'autocomplete' do
    let(:emrob_jones) { create :user, name: 'emrob jones' }
    let(:rob_jones) { create :user, name: 'rob jones' }
    let(:jim_robinson) { create :user, name: 'jim robinson' }
    let(:jim_emrob) { create :user, name: 'jim emrob' }
    let(:rob_othergroup) { create :user, name: 'rob othergroup' }

    context 'success' do
      before do
        emrob_jones
        rob_jones
        jim_robinson
        jim_emrob
        group.add_member!(emrob_jones)
        group.add_member!(rob_jones)
        group.add_member!(jim_robinson)
        group.add_member!(jim_emrob)
        another_group.add_member!(rob_othergroup)
      end
      it 'returns users filtered by query', focus: true do
        get :autocomplete, group_id: group.id, q: 'rob', format: :json

        user_ids = JSON.parse(response.body)['users'].map{|c| c['id']}

        expect(user_ids).to_not include emrob_jones.id
        expect(user_ids).to include rob_jones.id
        expect(user_ids).to include jim_robinson.id
        expect(user_ids).to_not include jim_emrob.id
        expect(user_ids).to_not include rob_othergroup.id
      end
    end

    context 'failure' do
      it 'does not allow access to an unauthorized group' do
        cant_see_me = create :group
        get :autocomplete, group_id: cant_see_me.id
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end
    end
  end

  describe 'invitables' do

    context 'success' do
      it 'returns users in shared groups' do
        get :invitables, group_id: group.id, q: 'beef', format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users memberships groups])
        users = json['users'].map { |c| c['id'] }
        groups = json['groups'].map { |g| g['id'] }
        expect(users).to include alien_named_biff.id
        expect(users).to include alien_named_bang.id
        expect(users).to_not include user_named_biff.id
        expect(groups).to include another_group.id
      end

      it 'includes the given search fragment' do
        get :invitables, group_id: group.id, q: 'beef', format: :json
        json = JSON.parse(response.body)
        search_fragments = json['users'].map { |c| c['search_fragment'] }
        expect(search_fragments.compact.uniq.length).to eq 1
        expect(search_fragments).to include 'beef'
      end

      it 'can search by email address' do
        get :invitables, group_id: group.id, q: 'beef@biff', format: :json
        json = JSON.parse(response.body)
        users = json['users'].map { |c| c['id'] }
        groups = json['groups'].map { |g| g['id'] }
        expect(users).to include alien_named_biff.id
      end

      it 'does not return duplicate users' do
        third_group = create(:group)
        third_group.users << user
        third_group.users << user_named_biff
        another_group.users << user_named_biff

        get :invitables, group_id: group.id, q: 'biff', format: :json
        json = JSON.parse(response.body)
        memberships = json['memberships'].map { |m| m['id'] }
        users = json['users'].map { |u| u['id'] }
        expect(users).to include user_named_biff.id
        expect(users.length).to eq memberships.length
      end

    end
  end

end
