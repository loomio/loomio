require 'rails_helper'

describe Griddler::EmailsController do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:discussion) { create(:discussion) }
  let(:griddler_params) {{
    u: user.id,
    k: user.email_api_key,
    d: discussion.id,
    mailinMsg: {
      html: "<html><body>Hi!</body></html>",
      text: "Hi!",
      subject: "Greetings!",
      from: [{ name: user.name, address: user.email }],
      to: [{address: "reply&d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@localhost"}],
      cc: [],
      headers: {}
    }
  }}

  before do
    discussion.group.add_member! user
    discussion.group.add_member! another_user
  end

  it "creates a comment via email" do
    expect { post :create, griddler_params }.to change { Comment.count }.by(1)
  end

  it "responds with 403 when user is not authorized" do
    griddler_params[:email_api_key] = nil
    post :create, griddler_params
    expect(response.status).to eq 403
  end
end
