require 'rails_helper'

describe LoginTokenService do
  describe 'create' do
    let(:user) { create :user }
    let(:uri) { URI::parse "http://#{ENV['CANONICAL_HOST']}/explore" }
    let(:bad_uri) { URI::parse "http://badhost.biz/explore" }

    it 'creates a new login token' do
      expect { LoginTokenService.create(actor: user, uri: uri) }.to change { user.login_tokens.count }.by(1)
    end

    it 'sends an email to the user' do
      expect { LoginTokenService.create(actor: user, uri: uri) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'does nothing if the actor is not logged in' do
      expect { LoginTokenService.create(actor: LoggedOutUser.new, uri: uri) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'stores a redirect uri' do
      LoginTokenService.create(actor: user, uri: uri)
      expect(LoginToken.last.redirect).to eq '/explore'
    end

    it 'does not store a redirect uri if the host is different' do
      LoginTokenService.create(actor: user, uri: bad_uri)
      expect(LoginToken.last.redirect).to eq nil
    end
  end
end
