require 'rails_helper'

def mailin_params(
  token: "handle+u=123&k=123",
  to: "Loomio Group <#{token}@#{ENV['REPLY_HOSTNAME']}>", 
  from: 'Suzy Senderson <sender@gmail.com>', 
  subject: "re: an important discussion", 
  body: "Hi everybody, this is my message!")
  {
    mailinMsg: {
      html: "<html><body>#{body}</body></html>",
      text: body,
      headers: {
        from: from,
        to: to,
        subject: subject
      }
    }.to_json
  }
end

describe ReceivedEmailsController do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create(:discussion, group: group) }
  let(:poll) { create(:poll, discussion: discussion) }
  let(:comment) { create(:comment, discussion: discussion) }

  before do
    discussion.group.add_member! user
    discussion.group.add_member! another_user
  end

  it "creates a reply to comment via email" do
    h = mailin_params(
      to: "c=#{comment.id}&d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@#{ENV['REPLY_HOSTNAME']}", 
      body: "yo"
    )
    expect { post :create, params: h}.to change { Comment.count }.by(1)
    c = Comment.last
    expect(c.author).to eq user
    expect(c.parent).to eq comment
    expect(c.discussion).to eq discussion
    expect(c.body).to eq 'yo'
  end

  it "creates a comment on a poll via email" do
    h = mailin_params(
      to: "pt=p&pi=#{poll.id}&d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@#{ENV['REPLY_HOSTNAME']}", 
      body: "yo"
    )
    expect { post :create, params: h }.to change { Comment.count }.by(1)
    c = Comment.last
    expect(c.author).to eq user
    expect(c.parent).to eq poll
    expect(c.discussion).to eq discussion
    expect(c.body).to eq "yo"
  end

  it "creates a comment via email without a parent" do
    h = mailin_params(
      to: "d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@#{ENV['REPLY_HOSTNAME']}", 
      body: "yo"
    )
    expect { post :create, params: h}.to change { Comment.count }.by(1)
    c = Comment.last
    expect(c.author).to eq user
    expect(c.parent).to eq discussion
    expect(c.discussion).to eq discussion
    expect(c.body).to eq 'yo'
  end

  it "starts a discussion in a group" do
    h = mailin_params(
      to: "#{group.handle}+u=#{user.id}&k=#{user.email_api_key}@#{ENV['REPLY_HOSTNAME']}", 
      body: "yo I am a discussion"
    )
    expect { post :create, params: h}.to change { Discussion.count }.by(1)
    d = Discussion.last
    expect(d.author).to eq user
    expect(d.body).to eq "yo I am a discussion"
  end

  # describe "group-handle@hostname.com" do
  #   it "with new subject starts a discussion" do
  #     h = mailin_params(
  #       to: "#{group.handle}@#{ENV['REPLY_HOSTNAME']}", 
  #       subject: "the topic at hand",
  #       body: "greetings earthlings"
  #     )
  #     expect { post :create, params: h}.to change { Discussion.count }.by(1)
  #     d = Discussion.last
  #     expect(d.author).to eq user
  #     expect(d.body).to eq "greetings earthlings"
  #   end

  #   it "with existing subject adds comment to discussion" do
  #     h = mailin_params(
  #       to: "#{group.handle}@#{ENV['REPLY_HOSTNAME']}", 
  #       subject: "re: the topic at hand",
  #       body: "greetings earthlings"
  #     )
  #     expect { post :create, params: h}.to change { Discussion.count }.by(1)
  #     d = Discussion.last
  #     expect(d.author).to eq user
  #     expect(d.body).to eq "greetings earthlings"
  #   end
  # end

  # it "does not create a comment when the user is not authorized" do
  #   griddler_params[:mailinMsg][:to] = [{address: "reply&d=#{discussion.id}&u=#{user.id}&k=#{another_user.email_api_key}"}]
  #   expect { post :reply, params: griddler_params }.to_not change { Comment.count }
  #   expect(response.status).to eq 200
  # end
end
