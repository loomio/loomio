require "spec_helper"

describe UserMailer do
  describe 'sends email on membership approval' do
    before :all do
      @user = User.make!
      @group = Group.make!
      @mail = UserMailer.group_membership_approved(@user, @group)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @mail.subject.should == "[Loomio: #{@group.name}] Membership approved."
    end

    #ensure that the receiver is correct
    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @mail.from.should == ['noreply@tautoko.co.nz']
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
end
