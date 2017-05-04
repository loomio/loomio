require 'rails_helper'

describe LoginTokenService do
  describe 'create' do
    let(:user) { create :user }

    it 'creates a new login token' do
      expect { LoginTokenService.create(actor: user) }.to change { user.login_tokens.count }.by(1)
    end

    it 'sends an email to the user' do
      expect { LoginTokenService.create(actor: user) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'does nothing if the actor is not logged in' do
      expect { LoginTokenService.create(actor: LoggedOutUser.new) }.to_not change { ActionMailer::Base.deliveries.count }
    end
  end
end
