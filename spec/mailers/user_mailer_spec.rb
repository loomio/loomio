require "spec_helper"

describe UserMailer do
  context 'sending email on membership approval' do
    before :all do
      @user = User.make!
      @group = Group.make!
      @mail = UserMailer.group_membership_approved(@user, @group)
    end

    it 'renders the subject' do
      @mail.subject.should == "[Loomio: #{@group.full_name}] Membership approved"
    end

    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end

    it 'assigns correct reply_to' do
      @mail.reply_to.should == [@group.admin_email]
    end

    it 'renders the sender email' do
      @mail.from.should == ['noreply@loom.io']
    end

    it 'assigns the @name variable which appears in the email body' do
      @mail.body.encoded.should match(@group.full_name)
    end

    it 'assigns confirmation_url for email body' do
      @mail.body.encoded.should match("http://localhost:3000/groups/#{@group.id}")
    end
  end

  context 'sending email when user is added to a group' do
    before :all do
      @user = User.make!
      @group = Group.make!
      @mail = UserMailer.added_to_group(@user, @group)
    end

    it 'renders the subject' do
      @mail.subject.should match(/been added to a group/)
    end
    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end
    
    it 'assigns reply to' do
      @mail.reply_to.should == [@group.admin_email]
    end
    
    it 'renders the sender email' do
      @mail.from.should == ['noreply@loom.io']
    end

    it 'assigns the groups name which appears in the email body' do
      @mail.body.encoded.should match(@group.full_name)
    end

    it 'assigns confirmation_url for email body' do
      @mail.body.encoded.should match("http://localhost:3000/groups/#{@group.id}")
    end
  end

  context 'sending email when user is invited to loomio' do
    before :all do
      @inviter = User.make
      @group = Group.make!
      @user = User.invite_and_notify!({email: "test@example.com"}, @inviter, @group)
      @mail = UserMailer.invited_to_loomio(@user, @inviter, @group)
    end

    it 'renders the subject' do
      @mail.subject.should match(
        /#{@inviter.name} has invited you to #{@group.full_name} on Loomio/)
    end

    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end

    it 'renders the sender email' do
      @mail.from.should == ['noreply@loom.io']
    end
    
    it 'assigns correct reply_to' do
      @mail.reply_to.should == [@group.admin_email]
    end

    it 'assigns the groups name which appears in the email body' do
      @mail.body.encoded.should match(@group.full_name)
    end

    it 'assigns inviters name which appears in the email body' do
      @mail.body.encoded.should match(@inviter.name)
    end

    it 'assigns invite_url for email body' do
      @mail.body.encoded.should match(@user.invitation_token)
    end
  end
end
