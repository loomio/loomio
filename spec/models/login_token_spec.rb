require 'rails_helper'

describe LoginToken do
  let(:token) { create :login_token }

  it 'has a token' do
    expect(create(:login_token).token).to be_present
  end

  it 'is useable by default' do
    expect(token.useable?).to eq true
  end

  it 'is not useable if it has been used before' do
    token.update(used: true)
    expect(token.useable?).to eq false
  end

  it 'is not useable if it is old' do
    token.update(created_at: 30.minutes.ago)
    expect(token.useable?).to eq false
  end
end
