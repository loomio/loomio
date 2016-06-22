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
      to: [], # we're stubbing out to with the value below
      cc: [],
      headers: {}
    }
  }}
  let(:email_params) { EmailParams.new(
    OpenStruct.new(
      to: [{
        host: "loomiohost.org",
        token: "reply&d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}"
      }],
      body: "This is a comment!"),
    reply_host: "loomiohost.org")
  }

  before do
    discussion.group.add_member! user
    discussion.group.add_member! another_user
  end

  it "creates a comment via email" do
    expect(EmailParams).to receive(:new).and_return(email_params)
    expect { post :create, griddler_params }.to change { Comment.count }.by(1)
  end

  it "does not create a comment when the user is not authorized" do
    griddler_params[:mailinMsg][:to] = [{address: "reply&d=#{discussion.id}&u=#{user.id}&k=#{another_user.email_api_key}"}]
    expect { post :create, griddler_params }.to_not change { Comment.count }
    expect(response.status).to eq 200
  end
end
