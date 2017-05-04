require 'rails_helper'

describe LoginToken do
  let(:token) { create :login_token }

  it 'has a token' do
    expect(create(:login_token).token).to be_present
  end

  it 'is useable by default' do
    expect(LoginToken.useable).to include token
  end

  it 'is not useable if it has been used before' do
    token.update(used: true)
    expect(LoginToken.useable).to_not include token
  end

  it 'is not useable if it is old' do
    token.update(created_at: 30.minutes.ago)
    expect(LoginToken.useable).to_not include token
  end
end
