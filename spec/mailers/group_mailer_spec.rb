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
      pending "This spec is failing on travis for some reason..."
      @mail.reply_to.should == [@group.admin_email]
    end

    it 'assigns confirmation_url for email body' do
      @mail.body.encoded.should match(/\/groups\/#{@group.id}/)
    end
  end

  describe "#deliver_group_email" do
    let(:group) { stub_model Group }

    it "sends email to every group member except the sender" do
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
  end

  describe "#group_email" do
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

  # describe "#invite_to_group" do
  #   before :each do
  #     @recipient_email = "newperson@testgroupy.com"
  #     @invite = double(:inviter_name => "Bloop",
  #                      :inviter_email => "goobly@goog.com",
  #                      :group_full_name => "Newww group",
  #                      :token => "asbglkh")
  #     @mail = GroupMailer.invite_to_group(@recipient_email, @invite)
  #   end

  #   subject { @mail }

  #   its(:subject) { should eq("#{@invite.inviter_name} has invited you to join " +
  #                             "#{@invite.group_full_name} on Loomio") }
  #   its(:to) { should eq([@recipient_email]) }
  #   its(:from) { should eq(["contact@loom.io"]) }
  #   its(:reply_to) { should eq([@invite.inviter_email]) }
  #   its(:body) { should match(/#{@invite.token}/) }
  # end
end
