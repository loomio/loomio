require 'rails_helper'
describe API::ProfileController do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:another_user) { create :user }
  let(:user_params) { { name: "new name", email: "new@email.com" } }

  describe 'show' do
    before { sign_in user }
    it 'returns the user json' do
      get :show, id: another_user.key, format: :json
      json = JSON.parse(response.body)
      expect(json.keys).to include *(%w[users])
      expect(json['users'][0].keys).to include *(%w[
        id
        key
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
      get :show, id: another_user.username, format: :json
      json = JSON.parse(response.body)
      expect(json['users'][0]['username']).to eq another_user.username
    end

    it 'does not return a deactivated user' do
      another_user.update deactivated_at: 1.day.ago
      get :show, id: another_user.key, format: :json
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
        post :update_profile, user: { avatar_kind: 'initials' }
        expect(response).to be_success
        expect(user.reload.avatar_kind).to eq 'initials'
      end

      it "updates a users profile" do
        post :update_profile, user: user_params, format: :json
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
        post :set_volume, volume: "quiet", format: :json
        group.add_member! user
        membership = group.membership_for(user)
        expect(user.default_membership_volume).to eq "quiet"
        expect(membership.volume).to eq "quiet"
      end

      it "sets the volume for all of a user's current memberships" do
        group.add_member! user
        membership = group.membership_for(user)
        post :set_volume, volume: "quiet", apply_to_all: true, format: :json
        expect(user.default_membership_volume).to eq "quiet"
        expect(membership.reload.volume).to eq "quiet"
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        user_params[:dontmindme] = 'wild wooly byte virus'
        post :update_profile, user: user_params, format: :json
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
        post :upload_avatar, file: fixture_for('images', 'strongbad.png')
        expect(response.status).to eq 200
        expect(user.reload.avatar_kind).to eq 'uploaded'
        expect(user.reload.uploaded_avatar).to be_present
      end
    end

    context 'failure' do
      it 'does not upload an invalid file' do
        user.update avatar_kind: 'gravatar'
        post :upload_avatar, file: fixture_for('images', 'strongbad.png', filetype: 'text/pdf')
        expect(response.status).to_not eq 200
        expect(user.reload.avatar_kind).to eq 'gravatar'
        expect(user.reload.uploaded_avatar).to be_blank
      end
    end
  end

  describe 'change_password' do
    before { sign_in user }
    context 'success' do
      it "changes a users password" do
        old_password = user.encrypted_password
        post :change_password, user: { current_password: 'complex_password', password: 'new_password', password_confirmation: 'new_password'}, format: :json
        expect(response).to be_success
        expect(user.reload.encrypted_password).not_to eq old_password
        json = JSON.parse(response.body)
        user_emails = json['users'].map { |v| v['email'] }
        expect(user_emails).to include user.email
      end
    end

    context 'failures' do
      it 'does not allow a change if current password does not match' do
        old_password = user.encrypted_password
        post :change_password, user: { current_password: 'not right', password: 'new_password', password_confirmation: 'new_password'}, format: :json
        expect(response).to_not be_success
        expect(user.reload.encrypted_password).to eq old_password
      end

      it 'does not allow a change if passord confirmation doesnt match' do
        old_password = user.encrypted_password
        post :change_password, user: { password: 'new_password', password_confirmation: 'errwhoops'}, format: :json
        expect(response).to_not be_success
        expect(user.reload.encrypted_password).to eq old_password
      end
    end
  end

  describe 'deactivate' do
    before { sign_in user }
    context 'success' do
      it "deactivates the users account" do
        post :deactivate, user: {deactivation_response: '' }, format: :json
        expect(response).to be_success
        json = JSON.parse(response.body)
        user_emails = json['users'].map { |v| v['email'] }
        expect(user_emails).to include user.email
        expect(user.reload.deactivated_at).to be_present
        expect(UserDeactivationResponse.last).to be_blank
      end

      it 'can record a deactivation response' do
        post :deactivate, user: { deactivation_response: '(╯°□°)╯︵ ┻━┻'}, format: :json
        deactivation_response = UserDeactivationResponse.last
        expect(deactivation_response.body).to eq '(╯°□°)╯︵ ┻━┻'
        expect(deactivation_response.user).to eq user
      end
    end
  end

  describe 'save_experience' do
    before { sign_in user }

    it 'successfully saves an experience' do
      post :save_experience, experience: :happiness
      expect(response.status).to eq 200
      expect(user.reload.experiences['happiness']).to eq true
    end

    it 'responds with forbidden when user is logged out' do
      @controller.stub(:current_user).and_return(LoggedOutUser.new)
      post :save_experience, experience: :happiness
      expect(response.status).to eq 403
    end

    it 'responds with bad request when no experience is given' do
      post :save_experience
      expect(response.status).to eq 400
    end
  end

end
