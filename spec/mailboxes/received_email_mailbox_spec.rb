require "rails_helper"

RSpec.describe ReceivedEmailMailbox, type: :mailbox do
  include ActionMailbox::TestHelper

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

  it "ignores emails from reply_hostname" do
    ForwardEmailRule.create(handle: 'homer', email: "homer@simpson.com")

    receive_inbound_email_from_mail(
      to: "homer@reply.loomio.test",
      from: "someone@reply.loomio.test",
      subject: "anything in the subject",
      body: "body example"
    )

    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it "decodes RFC 2047 encoded subject headers" do
    # Create a raw email with RFC 2047 encoded subject
    # =?UTF-8?Q?Caf=C3=A9?= should decode to "Café"
    from_email = user.name_and_email
    to_address = "#{group.handle}@#{ENV['REPLY_HOSTNAME']}"

    raw_email = Mail.new do
      from    from_email
      to      to_address
      subject "=?UTF-8?Q?Caf=C3=A9_discussion_about_na=C3=AFve_approach?="
      body    "Test body with encoded subject"
    end

    expect {
      receive_inbound_email_from_source(raw_email.to_s)
    }.to change { Discussion.count }.by(1)

    discussion = Discussion.last
    email = ReceivedEmail.last

    # Verify the subject is decoded in the headers hash
    expect(email.headers['Subject']).to eq 'Café discussion about naïve approach'
    expect(discussion.title).to eq 'Café discussion about naïve approach'
  end

  it "decodes RFC 2047 encoded from headers" do
    # Test that From header with encoded display name is also decoded
    # =?UTF-8?Q?Bj=C3=B6rk?= <test@example.com> should decode to "Björk <test@example.com>"
    from_header = "=?UTF-8?Q?Bj=C3=B6rk?= <#{user.email}>"
    to_address = "#{group.handle}@#{ENV['REPLY_HOSTNAME']}"

    raw_email = Mail.new do
      from    from_header
      to      to_address
      subject "Test subject"
      body    "Test body"
    end

    expect {
      receive_inbound_email_from_source(raw_email.to_s)
    }.to change { Discussion.count }.by(1)

    email = ReceivedEmail.last

    # Verify the From header is decoded
    expect(email.headers['From']).to include 'Björk'
  end

  # it "forwards specific emails to contact" do
  #   ForwardEmailRule.create(handle: 'support', email: "support@loomio.org")

  #   receive_inbound_email_from_mail(
  #     to: "support@reply.loomio.test",
  #     from: "someone@gmail.com",
  #     subject: "anything",
  #     body: "something"
  #   )

  #   last_email = ActionMailer::Base.deliveries.last
  #   expect(last_email.to).to include "support@loomio.org"
  # end

  it "creates a reply to comment via email" do
    comment
    expect {
      receive_inbound_email_from_mail(
        to: "c=#{comment.id}&d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com",
        body: "reply to comment via email"
      )
    }.to change { Comment.count }.by(1)
    c = Comment.last
    expect(c.author).to eq user
    expect(c.parent).to eq comment
    expect(c.discussion).to eq discussion
    expect(c.body).to eq 'reply to comment via email'
  end

  it "creates a comment on a poll via email" do
    expect {
      receive_inbound_email_from_mail(
        from: "hello@example.com",
        to: "pt=p&pi=#{poll.id}&d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@#{ENV['REPLY_HOSTNAME']}",
        body: "comment on a poll via email"
      )
    }.to change { Comment.count }.by(1)
    c = Comment.last
    expect(c.author).to eq user
    expect(c.parent).to eq poll
    expect(c.discussion).to eq discussion
    expect(c.body).to eq "comment on a poll via email"
  end

  it "creates a comment via email without a parent" do
    expect {
      receive_inbound_email_from_mail(
        from: "hello@example.com",
        to: "d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@#{ENV['REPLY_HOSTNAME']}",
        body: "comment via email without a parent"
      )
    }.to change { Comment.count }.by(1)
    c = Comment.last
    expect(c.author).to eq user
    expect(c.parent).to eq discussion
    expect(c.discussion).to eq discussion
    expect(c.body).to eq 'comment via email without a parent'
  end

  describe "group-handle@hostname.com" do
    it "invalid group handle" do
      expect {
        receive_inbound_email_from_mail(
          from: user.name_and_email,
          to: "invalid@#{ENV['REPLY_HOSTNAME']}",
          subject: "the topic at hand",
          body: "greetings earthlings"
        )
      }.to change { Discussion.count }.by(0)
      expect(ReceivedEmail.count == 0)
    end

    it "member email, starts a discussion" do
      expect {
        receive_inbound_email_from_mail(
          from: user.name_and_email,
          to: "#{group.handle}@#{ENV['REPLY_HOSTNAME']}",
          subject: "the topic at hand",
          body: "greetings earthlings"
        )
      }.to change { Discussion.count }.by(1)
      d = Discussion.last
      expect(d.author).to eq user
      expect(d.group.handle).to eq group.handle
      expect(d.body).to eq "greetings earthlings"
      e = ReceivedEmail.last
      expect(e.released).to eq true
      expect(e.group_id).to eq group.id
    end

    it "email from alias creates notification" do
      receive_inbound_email_from_mail(
        from: 'alias@gmail.com',
        to: "#{group.handle}@#{ENV['REPLY_HOSTNAME']}",
        subject: "the topic at hand",
        body: "greetings earthlings"
      )

      email = ReceivedEmail.last
      expect(email.released).to eq false
      expect(email.group_id).to eq group.id

      expect(Event.where(kind: 'unknown_sender').count).to eq 1
      expect(Notification.count).to eq 1
      assert group.admins.first.group_ids.include? ReceivedEmail.first.group_id
      assert group.admins.first.can? :show, ReceivedEmail.first
    end

    it "validated member alias, starts a discussion" do
      a = MemberEmailAlias.create(
        user_id: user.id,
        email: 'memberalias@example.com',
        group_id: group.id,
        author_id: group.admins.first.id
      )

      expect {
        receive_inbound_email_from_mail(
          from: a.email,
          to: "#{group.handle}@#{ENV['REPLY_HOSTNAME']}",
          subject: "the topic at hand",
          body: "greetings earthlings"
        )
      }.to change { Discussion.count }.by(1)
      d = Discussion.last
      expect(d.author).to eq user
      expect(d.group.handle).to eq group.handle
      expect(d.body).to eq "greetings earthlings"
      e = ReceivedEmail.last
      expect(e.released).to eq true
      expect(e.group_id).to eq group.id
    end


    it "blocked member alias, does not start discussion" do
      a = MemberEmailAlias.create(
        user_id: nil,
        email: 'memberalias@example.com',
        group_id: group.id,
        author_id: group.admins.first.id
      )

      expect {
        receive_inbound_email_from_mail(
          from: a.email,
          to: "#{group.handle}@#{ENV['REPLY_HOSTNAME']}",
          subject: "the topic at hand",
          body: "greetings earthlings"
        )
      }.to change { Discussion.count }.by(0)
      e = ReceivedEmail.last
      expect(e.released).to eq false
      expect(e.group_id).to eq nil
    end

  end
end
