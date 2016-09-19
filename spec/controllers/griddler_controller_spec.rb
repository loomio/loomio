require 'rails_helper'

describe Griddler::EmailsController do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:discussion) { create(:discussion) }
  let(:griddler_params) {{
    mailinMsg: {
      html: "<html><body>Hi!</body></html>",
      text: "Hi!",
      subject: "Greetings!",
      from: [{ name: user.name, address: user.email }],
      to: [{address: "reply&d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@#{reply_host}"}],
      cc: [{name: user.name, address: user.email }],
      headers: {}
    }
  }}
  let(:email_params) { EmailParams.new(
    OpenStruct.new(
      to: [{
        host: reply_host,
        token: "reply&d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}"
      }],
      body: "This is a comment!"),
    reply_host: reply_host)
  }
  let(:reply_host) { ENV['REPLY_HOSTNAME'] || ENV['CANONICAL_HOST'] || 'loomiohost.org' }

  before do
    discussion.group.add_member! user
    discussion.group.add_member! another_user
  end

  it "creates a comment via email" do
    expect { post :create, params: griddler_params }.to change { Comment.count }.by(1)
  end

  it "does not create a comment when the user is not authorized" do
    griddler_params[:mailinMsg][:to] = [{address: "reply&d=#{discussion.id}&u=#{user.id}&k=#{another_user.email_api_key}"}]
    expect { post :create, params: griddler_params }.to_not change { Comment.count }
    expect(response.status).to eq 200
  end
end
