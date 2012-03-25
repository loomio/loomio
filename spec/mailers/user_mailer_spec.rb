require "spec_helper"

describe UserMailer do
  context 'sending email on membership approval' do
    before :all do
      @user = User.make!
      @group = Group.make!
      @mail = UserMailer.group_membership_approved(@user, @group)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @mail.subject.should == "[Loomio: #{@group.name}] Membership approved"
    end

    #ensure that the receiver is correct
    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @mail.from.should == ['noreply@loom.io']
    end

    #ensure that the @name variable appears in the email body
    it 'assigns group.name' do
      @mail.body.encoded.should match(@group.name)
    end

    #ensure that the @confirmation_url variable appears in the email body
    it 'assigns url_for group' do
      @mail.body.encoded.should match("http://localhost:3000/groups/#{@group.id}")
    end
  end

  context 'sending email when user is added to a group' do
    before :all do
      @user = User.make!
      @group = Group.make!
      @mail = UserMailer.added_to_group(@user, @group)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @mail.subject.should match(/been added to a group/)
    end

    #ensure that the receiver is correct
    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @mail.from.should == ['noreply@loom.io']
    end

    #ensure that the @name variable appears in the email body
    it 'assigns group.name' do
      @mail.body.encoded.should match(@group.name)
    end

    #ensure that the @confirmation_url variable appears in the email body
    it 'assigns url_for group' do
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

    #ensure that the subject is correct
    it 'renders the subject' do
      @mail.subject.should match(
        /#{@inviter.name} has invited you to #{@group.name} on Loomio/)
    end

    #ensure that the receiver is correct
    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @mail.from.should == ['noreply@loom.io']
    end

    #ensure that the group's name appears in the email body
    it 'assigns group.name' do
      @mail.body.encoded.should match(@group.name)
    end

    #ensure that the inviter's name appears in the email body
    it 'assigns group.name' do
      @mail.body.encoded.should match(@inviter.name)
    end

    #ensure that the invite url appears in the email body
    it 'assigns url_for group' do
      @mail.body.encoded.should match(@user.invitation_token)
    end
  end
end
