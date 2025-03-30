require 'rails_helper'

describe WebpushService do
  it 'initializes vapid cert' do
    expect(WebpushService.vapid_cert.nil?).to eq false
  end

end
