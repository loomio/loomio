require 'rails_helper'
describe API::ProfileController do

  let(:user) { create :user }
  let(:group) { create :formal_group }
  let(:another_user) { create :user }
  let(:user_params) { { name: "new name", email: "new@email.com" } }

  describe 'show' do
    before { sign_in user }
    it 'returns the user json' do
      get :show, params: { id: another_user.key }, format: :json
      json = JSON.parse(response.body)
      expect(json.keys).to include *(%w[users])
      expect(json['users'][0].keys).to include *(%w[
        id
        name
        username
        avatar_initials
        avatar_kind
        time_zone
        search_fragment
        label])
      expect(json['users'][0].keys).to_not include 'email'
      expect(json['users'][0]['name']).to eq another_user.name
    end

    it 'can fetch a user by username' do
      get :show, params: { id: another_user.username }, format: :json
      json = JSON.parse(response.body)
      expect(json['users'][0]['username']).to eq another_user.username
    end

    it 'does not return a deactivated user' do
      another_user.update deactivated_at: 1.day.ago
      get :show, params: { id: another_user.key }, format: :json
      expect(response.status).to eq 403
      expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
    end
  end

  describe 'me' do
    it 'returns the current user data' do
      sign_in user
      get :me, format: :json
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.dig('users', 0, 'id')).to eq user.id
    end

    it 'returns unauthorized for visitors' do
      get :me, format: :json
      expect(response.status).to eq 403
    end
  end

  describe 'update_profile' do
    before { sign_in user }
    context 'success' do
      it 'updates a users profile picture type' do
        user.update avatar_kind: 'gravatar'
        post :update_profile, params: { user: { avatar_kind: 'initials' } }
        expect(response).to be_success
        expect(user.reload.avatar_kind).to eq 'initials'
      end

      it "updates a users profile" do
        post :update_profile, params: { user: user_params }, format: :json
        expect(response).to be_success
        expect(user.reload.email).to eq user_params[:email]
        json = JSON.parse(response.body)
        user_emails = json['users'].map { |v| v['email'] }
        expect(user_emails).to include user_params[:email]
      end
    end
  end

  describe 'set_volume' do
    before { sign_in user }

    context 'success' do
      it "sets a default volume for all of a user's new memberships" do
        post :set_volume, params: { volume: "quiet" }, format: :json
        group.add_member! user
        membership = group.membership_for(user)
        expect(user.default_membership_volume).to eq "quiet"
        expect(membership.volume).to eq "quiet"
      end

      it "sets the volume for all of a user's current memberships" do
        group.add_member! user
        membership = group.membership_for(user)
        post :set_volume, params: { volume: "quiet", apply_to_all: true }, format: :json
        expect(user.default_membership_volume).to eq "quiet"
        expect(membership.reload.volume).to eq "quiet"
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        user_params[:dontmindme] = 'wild wooly byte virus'
        post :update_profile, params: { user: user_params }, format: :json
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end
    end
  end

  describe 'upload_avatar' do
    before { sign_in user }
    context 'success' do
      it 'updates a users profile picture when uploaded' do
        user.update avatar_kind: 'gravatar'
        allow_any_instance_of(Paperclip::Attachment).to receive(:save).and_return(true)
        post :upload_avatar, params: { file: fixture_for('images/strongbad.png') }
        expect(response.status).to eq 200
        expect(user.reload.avatar_kind).to eq 'uploaded'
        expect(user.reload.uploaded_avatar).to be_present
      end
    end

    context 'failure' do
      it 'does not upload an invalid file' do
        user.update avatar_kind: 'gravatar'
        post :upload_avatar, params: { file: fixture_for('images/strongmad.pdf') }
        expect(response.status).to_not eq 200
        expect(user.reload.avatar_kind).to eq 'gravatar'
        expect(user.reload.uploaded_avatar).to be_blank
      end
    end
  end

  describe 'deactivate' do
    before { sign_in user }
    context 'success' do
      it "deactivates the users account" do
        post :deactivate, params: {user: {deactivation_response: '' }}, format: :json
        expect(response).to be_success
        json = JSON.parse(response.body)
        user_emails = json['users'].map { |v| v['email'] }
        expect(user_emails).to include user.email
        expect(user.reload.deactivated_at).to be_present
        expect(UserDeactivationResponse.last).to be_blank
      end

      it 'can record a deactivation response' do
        post :deactivate, params: { user: { deactivation_response: '(╯°□°)╯︵ ┻━┻'} }, format: :json
        deactivation_response = UserDeactivationResponse.last
        expect(deactivation_response.body).to eq '(╯°□°)╯︵ ┻━┻'
        expect(deactivation_response.user).to eq user
      end
    end
  end

  describe 'save_experience' do
    before { sign_in user }

    it 'successfully saves an experience' do
      post :save_experience, params: { experience: :happiness }
      expect(response.status).to eq 200
      expect(user.reload.experiences['happiness']).to eq true
    end

    it 'responds with forbidden when user is logged out' do
      @controller.stub(:current_user).and_return(LoggedOutUser.new)
      post :save_experience, params: { experience: :happiness }
      expect(response.status).to eq 403
    end

    it 'responds with bad request when no experience is given' do
      post :save_experience
      expect(response.status).to eq 400
    end
  end

  describe "mentionable" do
    let(:user)  { create :user }
    let(:group) { create :formal_group }
    let!(:jennifer) { create :user, name: 'jennifer', username: 'queenie' }
    let!(:jessica)  { create :user, name: 'jeesica', username: 'queenbee' }
    let!(:emilio)   { create :user, name: 'emilio', username: 'coolguy' }

    # jennifer and emilio are in the group
    # jessica is not in the group

    before do
      group.add_member! user
      group.add_member! jennifer
      sign_in user
    end

    it "returns users with name matching fragment" do
      get :mentionable_users, params: {q: "je"}
      json = JSON.parse(response.body)
      user_ids = json['users'].map { |c| c['id'] }
      expect(user_ids).to     include jennifer.id
      expect(user_ids).to_not include jessica.id
      expect(user_ids).to_not include emilio.id
    end

    it "returns users with username matching fragment" do
      get :mentionable_users, params: {q: "qu"}
      json = JSON.parse(response.body)
      user_ids = json['users'].map { |c| c['id'] }
      expect(user_ids).to     include jennifer.id
      expect(user_ids).to_not include jessica.id
      expect(user_ids).to_not include emilio.id
    end
  end
end
