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
        expect(response.status).to eq 200
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

  describe 'delete' do
    before { sign_in user }
    context 'success' do
      it "deletes the users account" do
        post :destroy
        expect(response.status).to eq 200
        expect {user.reload}.to raise_error ActiveRecord::RecordNotFound
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
    let(:subgroup) { create :formal_group, parent: group}
    let(:completely_unrelated_group) { create :formal_group }
    let!(:jgroupmember) { create :user, name: 'rspecjgroupmember', username: 'rspecqueenie' }
    let!(:jalien)  { create :user, name: 'rspecjalien', username: 'rspecqueenbee' }
    let!(:esubgroupmember)   { create :user, name: 'rspecesubgroupmember', username: 'rspeccoolguy' }
    let!(:jguest)    { create :user, name: 'rspecjguest', username: 'rspecsomeguy' }
    let(:discussion) { create :discussion, group: group, author: user, private: true }

    # jgroupmember and esubgroupmember are in the group
    # jalien is not in the group

    before do
      group.add_member! user
      group.add_member! jgroupmember
      subgroup.add_member! esubgroupmember
      completely_unrelated_group.add_member! jalien
      discussion.guest_group.add_member! jguest
      sign_in user
    end

    it "returns users with name matching fragment" do
      get :mentionable_users, params: {q: "rspecjgr", group_id: group.id}
      user_ids = JSON.parse(response.body)['users'].map { |c| c['id'] }
      expect(user_ids).to eq [jgroupmember.id]
    end

    it "returns users with username matching fragment" do
      get :mentionable_users, params: {q: "rspecqu", group_id: group.id}
      user_ids = JSON.parse(response.body)['users'].map { |c| c['id'] }
      expect(user_ids).to eq [jgroupmember.id]
    end

    it "returns users from groups within the same organisation" do
      get :mentionable_users, params: {q: "rspecesub", group_id: group.id}
      user_ids = JSON.parse(response.body)['users'].map { |c| c['id'] }
      expect(user_ids).to eq [esubgroupmember.id]
    end

    it "returns users for the discussion" do
      get :mentionable_users, params: {q: "rspecjg", discussion_id: discussion.id}
      user_ids = JSON.parse(response.body)['users'].map { |c| c['id'] }
      expect(user_ids).to eq [jgroupmember.id, jguest.id]
    end

    it "doesn't return users from groups outside the organisation" do
      get :mentionable_users, params: {q: "rspecja", group_id: group.id}
      user_names = JSON.parse(response.body)['users'].map { |c| c['name'] }
      expect(user_names).to eq []
    end
  end
end
