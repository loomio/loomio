require "spec_helper"

describe GroupMailer do

  describe 'sends email on membership request' do
    before :all do
      @group = create(:group)
      @membership = @group.add_request!(create(:user))
      @mail = GroupMailer.new_membership_request(@membership)
    end
    
    it 'renders the subject' do
      @mail.subject.should ==
        "[Loomio: #{@group.full_name}] New membership request from #{@membership.user.name}"
    end

    it "sends email to group admins" do
      @mail.to.should == @group.admins.map(&:email)
    end

    it 'renders the sender email' do
      @mail.from.should == ['noreply@loom.io']
    end
    
    it 'assigns correct reply_to' do
      @mail.reply_to.should == [@group.admin_email]
    end
    
    it 'assigns confirmation_url for email body' do
      @mail.body.encoded.should match(/\/groups\/#{@group.id}/)
    end
  end

  describe "deliver_group_email" do
    let(:group) { stub_model Group }

    it "sends email to every group member except the sender and those with notifications disabled" do
      sender = stub_model User, :accepted_or_not_invited? => true
      member = stub_model User, :accepted_or_not_invited? => true
      invitee = stub_model User, :accepted_or_not_invited? => false
      group.stub(:users).and_return([sender, member, invitee])
      email_subject = "i have something really important to say!"
      email_body = "goobly"
      mailer = double "mailer"

      mailer.should_receive(:deliver)
      GroupMailer.should_receive(:group_email).
        with(group, sender, email_subject, email_body, member).
        and_return(mailer)
      GroupMailer.should_not_receive(:group_email).
        with(group, sender, email_subject, email_body, sender).
        and_return(mailer)
      GroupMailer.should_not_receive(:group_email).
        with(group, sender, email_subject, email_body, invitee).
        and_return(mailer)

      GroupMailer.deliver_group_email(group, sender,
                                      email_subject, email_body)
    end

    context "notifications disabled" do
      before do

      end

      it "does not send email" do
        sender = stub_model User, :accepted_or_not_invited? => true
        member = stub_model User, :accepted_or_not_invited? => true
        muted_user = stub_model User, :accepted_or_not_invited? => true, :receive_emails => false
        group.stub(:users).and_return([sender, member, muted_user])
        mailer = double "mailer"

        mailer.should_receive(:deliver)
        GroupMailer.should_receive(:group_email).
        with(group, sender, 'abc', 'def', member).
        and_return(mailer)
        GroupMailer.should_not_receive(:group_email).
          with(group, sender, 'abc', 'def', muted_user).
          and_return(mailer)
        GroupMailer.deliver_group_email(group, sender, 'abc', 'def')

      end

    end
  end

  describe "group_email" do
    before :all do
      @group = stub_model Group, :name => "Blue"
      @sender = stub_model User, :name => "Marvin"
      @recipient = stub_model User, :email => "hello@world.com"
      @subject = "meeby"
      @message = "what in the?!"
      @mail = GroupMailer.group_email(@group, @sender, @subject,
                                      @message, @recipient)
    end

    subject { @mail }

    its(:subject) { should == "[Loomio: #{@group.full_name}] #{@subject}" }

    its(:to) { should == [@recipient.email] }

    its(:from) { should == ['noreply@loom.io'] }
  end
end
