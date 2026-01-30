require 'rails_helper'
describe Api::V1::ProfileController do

  let(:user) { create :user }
  let(:group) { create :group }
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
        time_zone])
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
      expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
    end
  end

  describe 'me' do
    it 'returns the current user data' do
      sign_in user
      get :me, format: :json
      expect(response.status).to eq 200
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
        expect(response.status).to eq 200
        expect(user.reload.avatar_kind).to eq 'initials'
      end

      it "updates a users profile" do
        post :update_profile, params: { user: user_params }, format: :json
        expect(response.status).to eq 200
        expect(user.reload.email).to eq user_params[:email]
        json = JSON.parse(response.body)
        user_emails = json['users'].map { |v| v['email'] }
        expect(user_emails).to include user_params[:email]
      end

      context 'when LOOMIO_SSO_FORCE_USER_ATTRS is set' do
        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with('LOOMIO_SSO_FORCE_USER_ATTRS').and_return('true')
        end

        it 'ignores name, email, and username updates' do
          original_name = user.name
          original_email = user.email
          original_username = user.username
          
          post :update_profile, params: { user: { name: 'new name', email: 'new@email.com', username: 'newusername' } }, format: :json
          
          expect(response.status).to eq 200
          expect(user.reload.name).to eq original_name
          expect(user.reload.email).to eq original_email
          expect(user.reload.username).to eq original_username
        end

        it 'allows updates to other profile fields' do
          post :update_profile, params: { user: { short_bio: 'new bio', location: 'new location' } }, format: :json
          
          expect(response.status).to eq 200
          expect(user.reload.short_bio).to eq 'new bio'
          expect(user.reload.location).to eq 'new location'
        end
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
        expect(JSON.parse(response.body)['exception']).to include 'ActionController::UnpermittedParameters'
      end
    end
  end

  describe 'upload_avatar' do
    before { sign_in user }
    context 'success' do
      it 'updates a users profile picture when uploaded' do
        user.update avatar_kind: 'gravatar'
        post :upload_avatar, params: { file: fixture_for('images/strongbad.png') }
        expect(response.status).to eq 200
        expect(user.reload.avatar_kind).to eq 'uploaded'
        expect(user.reload.uploaded_avatar.attached?).to be true
      end
    end
  end

  describe 'deactivate' do
    before { sign_in user }
    context 'success' do
      it "deactivates the users account" do
        post :destroy, format: :json
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        user_emails = json['users'].map { |v| v['email'] }
        expect(user_emails).to include user.email
        expect(user.reload.deactivated_at).to be_present
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

  describe "contactable" do
    let(:user)  { create :user }
    let(:actor) { create :user }
    let(:group) { create :group }
    let(:discussion) { create :discussion, group: nil }
    let(:poll) { create :poll, group: nil }

    before do
      sign_in(user)
    end

    it 'unrelated' do
      get :contactable, params: {user_id: user.id}
      expect(response.status).to eq 403
    end

    it 'two group members' do
      group.add_member! user
      group.add_member! actor
      get :contactable, params: {user_id: user.id}
      expect(response.status).to eq 200
    end

    it 'two discussion members' do
      discussion.add_guest! user, discussion.author
      discussion.add_guest! actor, discussion.author
      get :contactable, params: {user_id: user.id}
      expect(response.status).to eq 200
    end

    it 'two poll members' do
      poll.add_guest! user, poll.author
      poll.add_guest! actor, poll.author
      get :contactable, params: {user_id: user.id}
      expect(response.status).to eq 200
    end

    it 'a membership requestor and a group member' do
      group.add_member! actor
      group.membership_requests.create!(requestor: user)
      get :contactable, params: {user_id: user.id}
      expect(response.status).to eq 200
    end
  end
end
