require 'rails_helper'

describe IdentityService do
  describe '.link_or_create' do
    let(:identity_params) do
      {
        identity_type: 'oauth',
        uid: 'oauth_user_123',
        email: 'user@example.com',
        name: 'OAuth User',
        access_token: 'token_123'
      }
    end

    context 'new identity, no user signed in, no existing user' do
      it 'creates new identity and new user' do
        identity = IdentityService.link_or_create(
          identity_params: identity_params,
          current_user: nil
        )

        expect(identity.uid).to eq 'oauth_user_123'
        expect(identity.email).to eq 'user@example.com'
        expect(identity.user).to be_present
        expect(identity.user.email).to eq 'user@example.com'
        expect(identity.user.name).to eq 'OAuth User'
        expect(identity.user.email_verified).to be true
      end
    end

    context 'new identity, no user signed in, verified user exists' do
      let!(:existing_user) { create :user, email: 'user@example.com', name: 'Original Name', email_verified: true }

      it 'links identity to existing user' do
        identity = IdentityService.link_or_create(
          identity_params: identity_params,
          current_user: nil
        )

        expect(identity.user).to eq existing_user
        expect(existing_user.reload.email_verified).to be true
        expect(existing_user.identities.count).to eq 1
      end
    end

    context 'new identity, no user signed in, unverified user exists' do
      let!(:existing_user) { create :user, email: 'user@example.com', name: 'Original Name', email_verified: false }

      it 'links identity to unverified user and marks email verified' do
        identity = IdentityService.link_or_create(
          identity_params: identity_params,
          current_user: nil
        )

        expect(identity.user).to eq existing_user

        existing_user.reload
        expect(existing_user.email_verified).to be true
      end
    end

    context 'new identity, user already signed in' do
      let!(:current_user) { create :user }

      it 'creates pending identity' do
        identity = IdentityService.link_or_create(
          identity_params: identity_params,
          current_user: current_user
        )

        expect(identity.user_id).to be_nil  # Pending, not linked
        expect(identity.email).to eq 'user@example.com'
        expect(current_user.identities.count).to eq 0  # Not linked to current user
      end
    end

    context 'existing identity exists' do
      let!(:user) { create :user }
      let!(:existing_identity) do
        create :identity,
               identity_type: 'oauth',
               uid: 'oauth_user_123',
               email: 'old_email@example.com',
               user: user
      end

      it 'updates identity attributes' do
        identity = IdentityService.link_or_create(
          identity_params: identity_params,
          current_user: nil
        )

        existing_identity.reload
        expect(existing_identity.email).to eq 'user@example.com'
        expect(existing_identity.name).to eq 'OAuth User'
        expect(existing_identity.access_token).to eq 'token_123'
        expect(existing_identity.user).to eq user
        expect(identity.user).to eq user
      end
    end

    context 'existing identity with different user linked' do
      let!(:other_user) { create :user, email: 'other@example.com' }
      let!(:current_user) { create :user, email: 'current@example.com' }
      let!(:existing_identity) do
        create :identity,
               identity_type: 'oauth',
               uid: 'oauth_user_123',
               user: other_user
      end

      it 'updates identity and returns it (will cause silent switch)' do
        identity = IdentityService.link_or_create(
          identity_params: identity_params,
          current_user: current_user
        )

        # Identity still belongs to other_user (not switched)
        existing_identity.reload
        expect(existing_identity.user).to eq other_user
        expect(existing_identity.email).to eq 'user@example.com'
        expect(identity.user).to eq other_user
      end
    end
  end

  describe 'pending identity cleanup' do
    let!(:user) { create :user }
    let!(:recent_pending) do
      create :identity,
             identity_type: 'oauth',
             uid: 'recent_pending_123',
             user: nil,
             created_at: 1.day.ago
    end

    let!(:stale_pending) do
      create :identity,
             identity_type: 'oauth',
             uid: 'stale_pending_456',
             user: nil,
             created_at: 10.days.ago
    end

    let!(:linked_identity) do
      create :identity,
             identity_type: 'oauth',
             uid: 'linked_789',
             user: user,
             created_at: 10.days.ago
    end

    it 'pending scope finds unlinked identities' do
      expect(Identity.pending.count).to eq 2
      expect(Identity.pending).to include(recent_pending, stale_pending)
    end

    it 'stale scope finds pending identities older than specified days' do
      expect(Identity.stale(days: 7).count).to eq 1
      expect(Identity.stale(days: 7)).to include(stale_pending)
      expect(Identity.stale(days: 7)).not_to include(recent_pending)
    end

    it 'stale scope does not include linked identities' do
      expect(Identity.stale(days: 7)).not_to include(linked_identity)
    end

    it 'deletes stale pending identities' do
      Identity.stale(days: 7).delete_all
      expect(Identity.stale(days: 7).count).to eq 0
      expect(Identity.find_by(id: recent_pending.id)).to be_present
      expect(Identity.find_by(id: linked_identity.id)).to be_present
      expect(Identity.find_by(id: stale_pending.id)).to be_nil
    end
  end
end
