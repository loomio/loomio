require 'rails_helper'

describe ReceivedEmailsController do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:discussion) { create(:discussion) }

  before do
    discussion.group.add_member! user
    discussion.group.add_member! another_user
  end

  describe "start thread via email" do
    let!(:group) { create(:formal_group, group_privacy: "secret", handle: 'test-group') }
    let(:discussion_params) { {
       from: [{ name: user.name, address: user.email }],
       to: [{address: "test-group@#{ENV['REPLY_HOSTNAME']}"}],
       subject: 'hot topic',
       text: 'this is a new discussion'
    }}

    before do
      group.add_member! user
    end

    it "replies with error if your email is not recognised" do
      post :create,
           params: {mailinMsg:
                     {from: [{ name: "Ulrich Unknown",
                               address: "urlich@example.com" }]}}

      expect(response.status).to eq 200
      expect(last_email.to).to include "urlich@example.com"
      expect(last_email.subject).to include "email address was not recognised"
    end

    it "replies with error if your group handle is not recognised" do
      post :create,
           params: {mailinMsg: {
              from: [{ name: user.name, address: user.email }],
              to: [{address: "unknown-group@#{ENV['REPLY_HOSTNAME']}"}]
           }}

      expect(response.status).to eq 200
      expect(last_email.to).to include user.email
      expect(last_email.subject).to include "is not a group"
    end

    it "creates discussion and sends reciept email" do
      expect { post :create, params: {mailinMsg: discussion_params} }.to change { Discussion.count }.by(1)
      expect(response.status).to eq 200
      d = Discussion.last
      expect(d.title).to eq "hot topic"
      expect(d.description).to eq "this is a new discussion"
      expect(d.author).to eq user
      expect(d.group).to eq group

      # expect confirmation email back to user?
      # expect(last_email.to).to include user.email
      # expect(last_email.subject).to include "is not a group"
    end

    it "notifies CC'd people"
  end

  describe "reply by email" do
    let!(:comment) { create(:comment, discussion: discussion) }

    let(:comment_params) {{
      mailinMsg: {
        from: [{ name: user.name, address: user.email }],
        to: [{
          address: "reply&d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@#{ENV['REPLY_HOSTNAME']}"
        }],
        text: "This is a comment!",
      }
    }}

    let(:reply_params) {{
      mailinMsg: {
        from: [{ name: user.name, address: user.email }],
        to: [{
          address: "reply&c=#{comment.id}&d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@#{ENV['REPLY_HOSTNAME']}"
        }],
        text: "This is a reply!",
      }
    }}

    before do
      discussion.group.add_member!(user)
    end

    it "creates a comment via email" do
      expect { post :create, params: comment_params }.to change { Comment.count }.by(1)
      c = Comment.last
      expect(c.author).to eq user
      expect(c.parent).to eq nil
      expect(c.discussion).to eq discussion
      expect(c.body).to eq "This is a comment!"
    end

    it "creates a reply comment via email" do
      expect { post :create, params: reply_params }.to change { Comment.count }.by(1)
      c = Comment.last
      expect(c.author).to eq user
      expect(c.parent).to eq comment
      expect(c.discussion).to eq discussion
      expect(c.body).to eq "This is a reply!"
    end

    it "does not create a comment when the user is not authorized" do
      comment_params[:mailinMsg][:to] = [{address: "reply&d=#{discussion.id}&u=#{user.id}&k=#{another_user.email_api_key}@#{ENV['REPLY_HOSTNAME']}"}]
      expect { post :create, params: comment_params }.to_not change { Comment.count }
      expect(response.status).to eq 400
    end
  end
end
