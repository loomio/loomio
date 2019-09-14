require 'rails_helper'

 describe Identities::Saml do

   let(:saml_url) { "https://example.onelogin.com/key" }
   let(:identity) { build(:saml_identity, custom_fields: { saml_url: saml_url }) }

   describe 'metadata' do
     it 'can generate metadata from a metadata url' do
       expect(identity.metadata).to be_present
     end
   end

   describe 'auth_url' do
     it 'can generate an auth url from a metadata url' do
       expect(identity.auth_url).to be_present
     end
   end

   describe 'expired' do
     let(:user) { create(:user, last_seen_at: 2.hours.ago) }
     let!(:identity) { create(:saml_identity, user: user, last_authenticated_at: 2.days.ago) }

     it 'includes expired identities' do
       expect(Identities::Saml.expired).to include identity
     end

     it 'does not include identities of those who were recently seen' do
       user.update(last_seen_at: 2.minutes.ago)
       expect(Identities::Saml.expired).to_not include identity
     end

     it 'does not include identities of those who were recently authenticated' do
       identity.update(last_authenticated_at: 2.hours.ago)
       expect(Identities::Saml.expired).to_not include identity
     end
   end

 end
