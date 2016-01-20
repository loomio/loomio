require "rails_helper"

describe GroupMailer do

  describe '#new_membership request' do
    it 'sends email to all the admins' do
      @group = create(:group)
      @membership_request = create(:membership_request, group: @group, name: 'bob jones', email: "bobby@jones.org")
      mailer = double "mailer"

      mailer.should_receive(:deliver_later)
      GroupMailer.should_receive(:membership_request).with(@group.admins.first, @membership_request).
        and_return(mailer)
      GroupMailer.new_membership_request(@membership_request)
    end
  end

  describe '#membership_request' do
    before do
      @group = create(:group)
      @admin = @group.admins.first
      @membership_request = create(:membership_request, group: @group, name: 'bob jones', email: "bobby@jones.org")
      @mail = GroupMailer.membership_request(@admin, @membership_request)
    end

    it 'renders the subject' do
      expect(@mail.subject).to eq "#{@membership_request.name} has requested to join #{@group.full_name}"
    end

    it "sends email to group admins" do
      expect(@mail.to).to eq [@admin.email]
    end

    context "requestor is an existing loomio user" do
      it 'renders the sender email' do
        expect(@mail.from).to eq ['notifications@loomio.org']
      end

      it 'assigns correct reply_to' do
        expect(@mail.reply_to).to eq [@membership_request.email]
      end

      it 'assigns confirmation_url for email body' do
        @mail.body.encoded.should match(/\/g\/#{@group.key}/)
      end
    end

    context "requestor is not a loomio user"
  end

  describe "#deliver_group_email" do
    let(:group) { stub_model Group }

    it "sends email to every group member except the sender" do
      sender = stub_model User
      member = stub_model User
      group.stub(:users).and_return([sender, member])
      email_subject = "i have something really important to say!"
      email_body = "goobly"
      mailer = double "mailer"

      mailer.should_receive(:deliver_later)
      GroupMailer.should_receive(:group_email).
        with(group, sender, email_subject, email_body, member).
        and_return(mailer)
      GroupMailer.should_not_receive(:group_email).
        with(group, sender, email_subject, email_body, sender)
      GroupMailer.deliver_group_email(group, sender,
                                      email_subject, email_body)
    end
  end
  
  describe "#group_email" do
    before :each do
      @group = stub_model Group, :name => "Blue", full_name: "Marvin: Blue", :admin_email => "goodbye@world.com", key: 'abc123'
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
    its(:from) { should == ['notifications@loomio.org'] }
  end

end
