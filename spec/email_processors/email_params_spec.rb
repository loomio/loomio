require 'rails_helper'

describe EmailParams do
  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion }
  let(:reply_host) { 'loomio.example.org' }
  let(:to_params) { {
    host: reply_host,
    token: "d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}"
  } }
  let(:email) { OpenStruct.new(to: [to_params], body: 'An email body') }

  before { group.add_member! user }
  subject { EmailParams.new(email, reply_host: reply_host) }

  it 'returns a hash of email values' do
    expect(subject.user_id.to_i).to eq user.id
    expect(subject.discussion_id.to_i).to eq discussion.id
    expect(subject.email_api_key).to eq user.email_api_key
    expect(subject.body).to eq email.body
  end

  it 'does not blow up if the host is not specified correctly' do
    to_params[:host] = 'notathing@example.com'
    expect(subject.user_id).to eq nil
  end

  it 'does not blow up if the token is mangled' do
    to_params[:token] = 'bargle'
    expect(subject.user_id).to eq nil
  end

end
