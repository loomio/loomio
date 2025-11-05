require 'rails_helper'

describe ReceivedEmailService do
  describe "Splitting replies" do
    it "splits spanish text reply" do
      input_body = "Me aparece que cumpla con los Criterio?\n\nEl lun, 3 de jun. de 2024 7:03 a. m., Deborah Mowesley (via Loomio) <\nnotifications@loomio.com> escribió:\n\n> \n>\n> [image: DM] sondeo cerrará en 24 horas\n>"
      output_body = ReceivedEmailService.extract_reply_body(input_body)
      expect(output_body).to eq "Me aparece que cumpla con los Criterio?"
    end

    it "splits spanish html reply" do
      input_body = "Me aparece que cumpla con los Criterio?\n\nEl lun, 3 de jun. de 2024 7:03 a.Â m., Deborah Mowesley (via Loomio) <notifications@loomio.com> escribiÃ³:\n\nï»¿ï»¿ï»¿ï»¿ï»¿ï»¿ï»¿ï»¿\n\nDM\n\n---------------------------\nsondeo cerrarÃ¡ en 24 horas\n---------------------------\n\n************************************************************************************************************************************************************************************************************************************************************\nI agree with the proposed agenda for the 2024 General Assembly. ( https://www.loomio.com/d/Wa1HJcwd/draft-agenda-borrador-de-agenda-projet-d-ordre-du-jour/1?stance_token=zThpg7pNBvKRRxutP4s4fRD4&utm_campaign=poll_closing_soon&utm_medium=email )\n************************************************************************************************************************************************************************************************************************************************************\n\nKey information Vote"
      output_body = ReceivedEmailService.extract_reply_body(input_body)
      expect(output_body).to eq "Me aparece que cumpla con los Criterio?"
    end

    it "splits joshuas reply" do
      input_body = "Yep, I’m happy for folks to jump in this week\nJ\n\nOn Tue, 7 Mar 2023 at 3:51 PM, jon g (via Loomio) <notifications@loomio.com> wrote:\n\n﻿﻿﻿﻿﻿﻿﻿﻿\n\nJG\n\n-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\njohn gieryn replied to you in: Are you in for season 1? ( https://www.loomio.com/d/1jq/comment/288?discussion_reader_token=Smeb&utm_campaign=user_mentioned&utm_medium=email )\n-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n\n@Ja Vi it sounds like I could get back to you (on \"are you in…\") in a day or two per your post in the other thread? 🙏\n\n—\n\nReply to this email directly or view it on Loomio ( https://www.loomio.com/d/1ajq/comment/28?discussion_reader_token=Smsweb&utm_campaign=user_mentioned&utm_medium=email ).\n\nLogo"
      output_body = ReceivedEmailService.extract_reply_body(input_body)
      expect(output_body).to eq "Yep, I’m happy for folks to jump in this week\nJ"
    end

    it "splits the email on 'in reply to (Loomio) address colon'" do
      input_body = "Hi I'm the bit you want
      On someday (Loomio) #{BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS} said:
      This is the bit that you don't want"
      output_body = ReceivedEmailService.extract_reply_body(input_body)
      expect(output_body).to eq "Hi I'm the bit you want"
    end

    it "splits the email on 'in reply to (Loomio) address colon'" do
      input_body = "Hi I'm the bit you want
      On someday (Loomio) bobo@notloomio.org wrote:
      This is the bit that you don't want"
      output_body = ReceivedEmailService.extract_reply_body(input_body)
      expect(output_body).to eq "Hi I'm the bit you want"
    end

    it "splits the email on the hidden chars" do
      input_body = "Hi I'm the bit you want
      #{EventMailer::REPLY_DELIMITER}
      This is the bit that you don't want"
      output_body = ReceivedEmailService.extract_reply_body(input_body)
      expect(output_body).to eq "Hi I'm the bit you want"
    end

    it "splits the email on signature" do
      input_body = "Hi I'm the bit you want
      --
      This is the bit that you don't want"
      output_body = ReceivedEmailService.extract_reply_body(input_body)
      expect(output_body).to eq "Hi I'm the bit you want"
    end

    it "splits the email signature without a line break" do
      author_name = "Charles Barclay"
      input_body = "Hi I'm the bit you want

      Charles Barclay
      CEO
      Some company
      +35 223333333
      \"Massive email signatures mean youre very professional\"
      "
      output_body = ReceivedEmailService.extract_reply_body(input_body, author_name)
      expect(output_body).to eq "Hi I'm the bit you want"
    end
  end

  describe 'strip subject' do
    it 'correctly strips re and fwd from subject lines' do
      [
        "Re: repairing the is fwd software",
        "Fwd: repairing the is fwd software",
        "RE: FW: repairing the is fwd software",
        "FW: RE: RE: repairing the is fwd software",
        " FW repairing the is fwd software",
        "RE repairing the is fwd software",
        "RE FWD: repairing the is fwd software",
        "RE: FW repairing the is fwd software",
      ].each do |line|
        expect(line.gsub(/^( *(re|fwd?)(:| ) *)+/i, '')).to eq "repairing the is fwd software"
      end
    end
  end

  describe 'notifications address routing' do
    it 'sends a delivery failure notice and destroys the email when sent to notifications address and not throttled' do
      email = double('ReceivedEmail',
        released: false,
        sender_email: 'user@example.com',
        sent_to_notifications_address?: true,
        sender_name_and_email: '"User" <user@example.com>'
      )

      expect(ThrottleService).to receive(:can?).with(key: 'bounce', id: 'user@example.com', max: 1, per: 'hour').and_return(true)
      expect(ForwardMailer).to receive(:bounce).with(to: '"User" <user@example.com>').and_return(double(deliver_now: true))
      expect(email).to receive(:destroy)

      ReceivedEmailService.route(email)
    end

    it 'does not send a delivery failure notice when throttled and still destroys the email' do
      email = double('ReceivedEmail',
        released: false,
        sender_email: 'user@example.com',
        sent_to_notifications_address?: false
      )
      allow(email).to receive(:sent_to_notifications_address?).and_return(true)

      expect(ThrottleService).to receive(:can?).with(key: 'bounce', id: 'user@example.com', max: 1, per: 'hour').and_return(false)
      expect(ForwardMailer).not_to receive(:bounce)
      expect(email).to receive(:destroy)

      ReceivedEmailService.route(email)
    end

    it 'destroys emails without a valid route when not sent to notifications address' do
      email = double('ReceivedEmail',
        released: false,
        sender_email: 'user@example.com',
        sent_to_notifications_address?: false,
        is_complaint?: false,
        complainer_address: nil,
        sender_hostname: 'example.com',
        route_address: nil
      )
      expect(email).to receive(:destroy)
      ReceivedEmailService.route(email)
    end
  end

  describe 'routing cases' do
    it 'increments complaints and releases email for complaint notifications' do
      email = double('ReceivedEmail',
        released: false,
        sender_email: 'user@example.com',
        sent_to_notifications_address?: false,
        is_complaint?: true,
        complainer_address: 'complainer@example.com'
      )

      expect(User).to receive(:where).with(email: 'complainer@example.com').and_return(double(update_all: 1))
      expect(email).to receive(:update).with(released: true)

      ReceivedEmailService.route(email)
    end

    it 'forwards using forward rule and destroys the email' do
      email = double('ReceivedEmail',
        released: false,
        sender_email: 'user@example.com',
        sent_to_notifications_address?: false,
        is_complaint?: false,
        complainer_address: nil,
        sender_hostname: 'example.com',
        route_address: 'foo@mail.host',
        route_path: 'foo',
        sender_name: 'Alice',
        from: '"Alice" <user@example.com>',
        subject: 'Hello',
        body_text: 'text body',
        body_html: '<p>html body</p>'
      )

      allow(ReceivedEmailService).to receive(:banned_sender_hosts).and_return([])
      expect(ForwardEmailRule).to receive(:find_by).with(handle: 'foo').and_return(double(email: 'target@example.com'))
      expect(ForwardMailer).to receive(:forward_message).with(
        from: "\"Alice\" <#{BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS}>",
        to: 'target@example.com',
        reply_to: '"Alice" <user@example.com>',
        subject: 'Hello',
        body_text: 'text body',
        body_html: '<p>html body</p>'
      ).and_return(double(deliver_now: true))
      expect(email).to receive(:destroy)

      ReceivedEmailService.route(email)
    end

    it 'creates a discussion for group handle when not blocked and actor is authorized' do
      group = double('Group', id: 123)
      actor = double('User')

      email = double('ReceivedEmail',
        released: false,
        sender_email: 'user@example.com',
        sent_to_notifications_address?: false,
        is_complaint?: false,
        complainer_address: nil,
        sender_hostname: 'example.com',
        route_address: 'group@mail.host',
        route_path: 'group',
        attachments: [],
        subject: 'Hello',
        full_body: 'Body',
        body_format: 'md'
      )

      allow(ReceivedEmailService).to receive(:banned_sender_hosts).and_return([])
      expect(Group).to receive(:find_by).with(handle: 'group').and_return(group)
      expect(ReceivedEmailService).to receive(:address_is_blocked).with(email, group).and_return(false)
      expect(email).to receive(:update).with(group_id: 123)
      expect(ReceivedEmailService).to receive(:actor_from_email_and_group).with(email, group).and_return(actor)
      allow(ReceivedEmailService).to receive(:discussion_params).with(email).and_return({})
      expect(DiscussionService).to receive(:create).with(hash_including(actor: actor, discussion: instance_of(Discussion)))
      expect(email).to receive(:update_attribute).with(:released, true)

      ReceivedEmailService.route(email)
    end

    it 'does not create a discussion when address is blocked' do
      group = double('Group', id: 123)

      email = double('ReceivedEmail',
        released: false,
        sender_email: 'user@example.com',
        sent_to_notifications_address?: false,
        is_complaint?: false,
        complainer_address: nil,
        sender_hostname: 'example.com',
        route_address: 'group@mail.host',
        route_path: 'group'
      )

      allow(ReceivedEmailService).to receive(:banned_sender_hosts).and_return([])
      expect(Group).to receive(:find_by).with(handle: 'group').and_return(group)
      expect(ReceivedEmailService).to receive(:address_is_blocked).with(email, group).and_return(true)
      expect(DiscussionService).not_to receive(:create)
      expect(email).not_to receive(:update_attribute).with(:released, true)

      ReceivedEmailService.route(email)
    end

    it 'destroys when sender hostname is banned' do
      email = double('ReceivedEmail',
        released: false,
        sender_email: 'user@example.com',
        sent_to_notifications_address?: false,
        is_complaint?: false,
        complainer_address: nil,
        sender_hostname: 'banned.com',
        route_address: 'anything@mail.host'
      )

      allow(ReceivedEmailService).to receive(:banned_sender_hosts).and_return(['banned.com'])
      expect(email).to receive(:destroy)

      ReceivedEmailService.route(email)
    end
  end

  describe 'email routing integration' do
    before do
      reset_email
    end

    def build_headers(from:, to:, subject: 'Test Subject')
      {
        'From' => from,
        'To' => to,
        'Subject' => subject
      }
    end

    it 'creates a comment for personal email-to-thread route and marks the email as released' do
      # Ensure reply host used in route address is recognized
      original_reply = ENV['REPLY_HOSTNAME']
      ENV['REPLY_HOSTNAME'] = 'test.host'

      user = create(:user)
      group = create(:group)
      group.add_member!(user)
      discussion = create(:discussion, group: group)

      route_local = "d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}"
      to = "#{route_local}@#{ENV['REPLY_HOSTNAME']}"
      from = "\"#{user.name}\" <#{user.email}>"

      email = ReceivedEmail.create!(
        headers: build_headers(from: from, to: to),
        body_text: "Hello from email"
      )

      expect {
        ReceivedEmailService.route(email)
      }.to change { Comment.count }.by(1)

      expect(email.reload.released).to eq true
      comment = Comment.last
      expect(comment.discussion_id).to eq discussion.id
      expect(comment.user_id).to eq user.id
    ensure
      ENV['REPLY_HOSTNAME'] = original_reply
    end

    it 'sends a delivery failure notice once per hour for replies to notifications address' do
      reset_email
      ThrottleService.reset!(:hour)

      user = create(:user)
      to = BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS
      from = "\"#{user.name}\" <#{user.email}>"

      email1 = ReceivedEmail.create!(
        headers: build_headers(from: from, to: to),
        body_text: "Wrong address reply 1"
      )

      expect {
        ReceivedEmailService.route(email1)
      }.to change { ActionMailer::Base.deliveries.size }.by(1)

      email2 = ReceivedEmail.create!(
        headers: build_headers(from: from, to: to),
        body_text: "Wrong address reply 2"
      )

      expect {
        ReceivedEmailService.route(email2)
      }.not_to change { ActionMailer::Base.deliveries.size }
    end

    it 'forwards using a forward rule and destroys the inbound email' do
      reset_email
      original_reply = ENV['REPLY_HOSTNAME']
      ENV['REPLY_HOSTNAME'] = 'test.host'

      create(:user) # ensure DB is initialized
      rule = ForwardEmailRule.create!(handle: 'foobar', email: 'target@example.com')

      user = create(:user)
      from = "\"#{user.name}\" <#{user.email}>"
      to = "foobar@#{ENV['REPLY_HOSTNAME']}"

      email = ReceivedEmail.create!(
        headers: build_headers(from: from, to: to, subject: 'Forward me'),
        body_text: "Forward body text",
        body_html: "<p>Forward body html</p>"
      )

      expect {
        ReceivedEmailService.route(email)
      }.to change { ActionMailer::Base.deliveries.size }.by(1)

      delivered = ActionMailer::Base.deliveries.last
      expect(delivered.to).to include(rule.email)
      # expect(delivered.reply_to).to include(from)
      expect(delivered.subject).to eq 'Forward me'

      expect(ReceivedEmail.where(id: email.id)).to be_blank
    ensure
      ENV['REPLY_HOSTNAME'] = original_reply
    end

    it 'creates a discussion for group handle and marks email as released' do
      original_reply = ENV['REPLY_HOSTNAME']
      ENV['REPLY_HOSTNAME'] = 'test.host'

      user = create(:user)
      group = create(:group, handle: 'grp123')
      group.add_member!(user)

      subject_line = 'New thread via email'
      from = "\"#{user.name}\" <#{user.email}>"
      to = "grp123@#{ENV['REPLY_HOSTNAME']}"
      body = "Thread body"

      email = ReceivedEmail.create!(
        headers: build_headers(from: from, to: to, subject: subject_line),
        body_text: body
      )

      expect {
        ReceivedEmailService.route(email)
      }.to change { Discussion.count }.by(1)

      discussion = Discussion.order(:id).last
      expect(discussion.group_id).to eq group.id
      expect(discussion.title).to eq subject_line
      expect(email.reload.released).to eq true
    ensure
      ENV['REPLY_HOSTNAME'] = original_reply
    end
  end
end
