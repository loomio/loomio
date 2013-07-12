require "spec_helper"

describe GroupMailer do

  describe 'sends email on membership request' do
    before :all do
      @group = create(:group)
      @group.add_admin!(create(:user))
      @membership_request = create(:membership_request, group: @group,
                                   name: 'bob jones', email: "bobby@jones.org")
      @mail = GroupMailer.new_membership_request(@membership_request)
    end

    context "requestor is an existing loomio user" do
      before { @membership_request.stub(:requestor, create(:user)) }
      it 'renders the subject' do
        @mail.subject.should ==
          "[Loomio: #{@group.full_name}] New membership request from #{@membership_request.name}"
      end

      it "sends email to group admins" do
        pending "for some reason this is failing on travis"
        @mail.to.should == @group.admins.map(&:email)
      end

      it 'renders the sender email' do
        @mail.from.should == ['noreply@loomio.org']
      end

      it 'assigns correct reply_to' do
        pending "This spec is failing on travis for some reason..."
        @mail.reply_to.should == [@group.admin_email]
      end

      it 'assigns confirmation_url for email body' do
        @mail.body.encoded.should match(/\/groups\/#{@group.id}/)
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

      mailer.should_receive(:deliver)
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
    before :all do
      @group = stub_model Group, :name => "Blue", :admin_email => "goodbye@world.com"
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
    its(:from) { should == ['noreply@loomio.org'] }
  end
end
