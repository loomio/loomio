require 'rails_helper'
describe Api::V1::MembershipsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:user_named_biff) { create :user, name: "Biff Bones" }
  let(:user_named_bang) { create :user, name: "Bang Whamfist" }
  let(:alien_named_biff) { create :user, name: "Biff Beef", email: 'beef@biff.com' }
  let(:alien_named_bang) { create :user, name: 'Bang Beefthrong' }
  let(:pending_named_barb) { create :user, name: 'Barb Backspace' }

  let(:group) { create :group }
  let(:another_group) { create :group }
  let(:subgroup) { create :group, parent: group }
  let(:discussion) { create :discussion, group: group }
  let(:comment_params) {{
    body: 'Yo dawg those kittens be trippin for some dippin',
    discussion_id: discussion.id
  }}

  before do
    group.add_admin! user
    group.add_member! user_named_biff
    group.add_member! user_named_bang
    another_group.add_member! user
    another_group.add_member! alien_named_bang
    another_group.add_member! alien_named_biff
    subgroup.add_member! user
    group.memberships.create!(user: pending_named_barb, accepted_at: nil)
    sign_in user
  end

  describe 'user_name' do
    let(:unverified_user) { create :user, email_verified: false }

    before do
      group.add_member!(unverified_user)
    end

    it 'allows group admin to set name of unverified user' do
      unverified_user.update(name: 'present')
      post :user_name, params: {id: unverified_user.id, name: 'celine', username: 'diva99'}
      expect(response.status).to eq 200
      expect(unverified_user.reload.name).to eq "celine"
      expect(unverified_user.reload.username).to eq "diva99"
    end

    it 'allows group admin to set name of verified, nil name user' do
      user_named_biff.update(email_verified: true, name: nil)
      post :user_name, params: {id: user_named_biff.id, name: 'celine', username: 'diva99'}
      expect(response.status).to eq 200
      expect(user_named_biff.reload.name).to eq "celine"
      expect(user_named_biff.reload.username).to eq "diva99"
    end

    it 'allows group admin to set name of verified, blank name user' do
      user_named_biff.update(email_verified: true, name: '')
      post :user_name, params: {id: user_named_biff.id, name: 'celine', username: 'diva99'}
      expect(response.status).to eq 200
      expect(user_named_biff.reload.name).to eq "celine"
      expect(user_named_biff.reload.username).to eq "diva99"
    end

    it 'disallows admin to set name,username of unverified user in other group' do
      Membership.where(group_id: group.id, user_id: unverified_user.id).delete_all
      post :user_name, params: {id: unverified_user.id, name: 'celine', username: 'diva99'}
      expect(response.status).to eq 403
    end

    it 'disallows non admin to set name,username of unverified user' do
      sign_in user_named_biff
      post :user_name, params: {id: unverified_user.id, name: 'celine', username: 'diva99'}
      expect(response.status).to eq 403
    end

    it 'disallows group admin to set name,username of verified user' do
      post :user_name, params: {id: user_named_biff.id, name: 'celine', username: 'diva99'}
      expect(response.status).to eq 403
    end
  end

  describe 'create' do
    it 'sets the membership volume' do
      new_group = FactoryBot.create(:group)
      user.update_attribute(:default_membership_volume, 'quiet')
      membership = Membership.create!(user: user, group: new_group)
      expect(membership.volume).to eq 'quiet'
    end
  end

  describe 'update' do
    it 'updates membership title, user titles, and broadcasts author to group' do
      m = group.membership_for(user_named_biff)
      post :update, params: { id: m.id, membership: {title: 'dr' } }
      expect(response.status).to eq 200
      expect(m.reload.title).to eq 'dr'
      expect(user_named_biff.reload.experiences['titles'][m.group_id.to_s]).to eq 'dr'
    end
  end

  describe 'resend' do
    let(:group) { create :group }
    let(:admin) { create :user }
    let(:member) { create :user }
    let(:membership) { create :membership, accepted_at: nil, inviter: admin, group: group }

    before do
      group.add_admin! admin
      group.add_member! member
    end

    it 'can resend a group invite' do
      sign_in admin
      expect { post :resend, params: { id: membership.id } }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(response.status).to eq 200
    end

    it 'does not send if not group admin' do
      sign_in member
      membership.update(inviter: create(:user))
      expect { post :resend, params: { id: membership.id } }.to_not change { ActionMailer::Base.deliveries.count }
      expect(response.status).to eq 403
    end

    it 'does not send if accepted' do
      sign_in admin
      membership.update(accepted_at: 1.day.ago)
      expect { post :resend, params: { id: membership.id } }.to_not change { ActionMailer::Base.deliveries.count }
      expect(response.status).to eq 403
    end
  end

  describe 'set_volume' do
    before do
      @discussion = FactoryBot.create(:discussion, group: group)
      @another_discussion = FactoryBot.create(:discussion, group: group)
      @membership = group.membership_for(user)
      @membership.set_volume! 'quiet'
      @second_membership = subgroup.membership_for(user)
      @second_membership.set_volume! 'quiet'
      @reader = DiscussionReader.for(discussion: @discussion, user: user)
      @reader.save!
      @reader.set_volume! 'normal'
      @second_reader = DiscussionReader.for(discussion: @another_discussion, user: user)
      @second_reader.save!
      @second_reader.set_volume! 'normal'
    end
    it 'updates the discussion readers' do
      put :set_volume, params: { id: @membership.id, volume: 'loud' }
      @reader.reload
      @second_reader.reload
      expect(@reader.computed_volume).to eq 'loud'
      expect(@second_reader.computed_volume).to eq 'loud'
    end
    context 'when apply to all is true' do
      it 'updates the volume for all memberships' do
        put :set_volume, params: { id: @membership.id, volume: 'loud', apply_to_all: true }
        @membership.reload
        @second_membership.reload
        expect(@membership.volume).to eq 'loud'
        expect(@second_membership.volume).to eq 'loud'
      end
    end
    context 'when apply to all is false' do
      it 'updates the volume for a single membership' do
        put :set_volume, params: { id: @membership.id, volume: 'loud'}
        @membership.reload
        @second_membership.reload
        expect(@membership.volume).to eq 'loud'
        expect(@second_membership.volume).not_to eq 'loud'
      end
    end
  end

  describe 'search via index' do
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
      it 'returns users filtered by query' do
        get :index, params: { group_id: group.id, q: 'rob' }, format: :json

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
        get :index, params: { group_id: cant_see_me.id }
        expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
      end
    end
  end

  describe 'index' do
    context 'success' do
      it 'returns users filtered by group' do
        get :index, params: { group_id: group.id }, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users memberships groups])
        users = json['users'].map { |c| c['id'] }
        groups = json['groups'].map { |g| g['id'] }
        expect(users).to include user_named_biff.id
        expect(users).to_not include alien_named_biff.id
        expect(users).to include pending_named_barb.id
        expect(groups).to include group.id
      end

      # it 'returns pending users' do
      #   get :index, params: { group_id: group.id, pending: true }, format: :json
      #   json = JSON.parse(response.body)
      #
      #   user_ids = json['users'].map { |c| c['id'] }
      #   groups = json['groups'].map { |g| g['id'] }
      #   expect(user_ids).to include pending_named_barb.id
      #   expect(groups).to include group.id
      # end

      context 'logged out' do
        before { @controller.stub(:current_user).and_return(LoggedOutUser.new) }
        let(:private_group) { create(:group, is_visible_to_public: false) }

        it 'returns no users for a public group' do
          group.update(group_privacy: 'open')
          get :index, params: { group_id: group.id }, format: :json
          json = JSON.parse(response.body)
          expect(json['memberships'].length).to eq 0
        end

        it 'responds with unauthorized for private groups' do
          get :index, params: { group_id: private_group.id }, format: :json
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
      private_group.add_member! another_user
      group.add_member! another_user

      get :for_user, params: { user_id: another_user.id }
      json = JSON.parse(response.body)
      group_ids = json['groups'].map { |g| g['id'] }
      expect(group_ids).to include group.id
      expect(group_ids).to_not include public_group.id
      expect(group_ids).to_not include private_group.id
    end
  end


  describe 'save_experience' do
    it 'successfully saves an experience' do
      membership = create(:membership, user: user)
      post :save_experience, params: { id: membership.id, experience: :happiness }
      expect(response.status).to eq 200
      expect(membership.reload.experiences['happiness']).to eq true
    end

    it 'responds with forbidden when user is logged out' do
      membership = create(:membership)
      post :save_experience, params: { id: membership.id, experience: :happiness }
      expect(response.status).to eq 403
    end
  end

  describe 'make_delegate' do
    it 'updates the membership record' do
      membership = group.add_member! another_user
      expect(membership.delegate).to be false
      expect(group.delegates_count).to eq 0
      post :make_delegate, params: {id: membership.id}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['memberships'][0]['delegate']).to be true
      expect(membership.reload.delegate).to be true
      expect(group.reload.delegates_count).to eq 1
    end

    it 'only works for group admins' do
      group.memberships.find_by(user_id: user.id).update(admin: false)
      membership = group.add_member! another_user
      post :make_delegate, params: {id: membership.id}
      expect(response.status).to eq 403
      expect(membership.reload.delegate).to be false
    end
  end

  describe 'remove_delegate' do
    it 'updates the membership record' do
      membership = group.add_member! another_user
      membership.update(delegate: true)
      expect(membership.delegate).to be true
      expect(group.reload.delegates_count).to eq 1
      post :remove_delegate, params: {id: membership.id}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['memberships'][0]['delegate']).to be false
      expect(membership.reload.delegate).to be false
      expect(group.reload.delegates_count).to eq 0
    end

    it 'only works for group admins' do
      group.memberships.find_by(user_id: user.id).update(admin: false)
      membership = group.add_member! another_user
      membership.update(delegate: true)
      post :remove_delegate, params: {id: membership.id}
      expect(response.status).to eq 403
      expect(membership.reload.delegate).to be true
    end
  end
end
