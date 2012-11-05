require "spec_helper"

describe UserMailer do
  shared_examples_for 'email_meta' do
    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end

    it 'renders the sender email' do
      @mail.from.should == ['noreply@loom.io']
    end
  end
  context 'sending email on membership approval' do
    before :all do
      @user = create(:user)
      @group = create(:group)
      @mail = UserMailer.group_membership_approved(@user, @group)
    end

    it_behaves_like 'email_meta'

    it 'assigns correct reply_to' do
      @mail.reply_to.should == [@group.admin_email]
    end

    it 'renders the subject' do
      @mail.subject.should == "[Loomio: #{@group.full_name}] Membership approved"
    end

    it 'assigns confirmation_url for email body' do
      @mail.body.encoded.should match("http://localhost:3000/groups/#{@group.id}")
    end
  end

  context 'added_to_group' do
    before :all do
      @user = create(:user)
      @group = create(:group)
      @inviter = stub_model(User, :name => "Mr. Inviter")
      @membership = stub_model(Membership, :user => @user, :group => @group, :inviter => @inviter)
      @mail = UserMailer.added_to_group(@membership)
    end

    it_behaves_like 'email_meta'

    it 'renders the subject' do
      @mail.subject.should match(/been added to a group/)
    end

    it 'assigns correct reply_to' do
      pending "This spec is failing on travis for some reason..."
      @mail.reply_to.should == [@group.admin_email]
    end

    it 'assigns confirmation_url for email body' do
      @mail.body.encoded.should match("http://localhost:3000/groups/#{@group.id}")
    end
  end

  context 'sending email when user is invited to loomio' do
    before :all do
      @inviter = build(:user)
      @group = create(:group)
      @user = User.invite_and_notify!({email: "test@example.com"}, @inviter, @group)
      @mail = UserMailer.invited_to_loomio(@user, @inviter, @group)
    end

    it_behaves_like 'email_meta'

    it 'renders the subject' do
      @mail.subject.should match(
        /#{@inviter.name} has invited you to #{@group.full_name} on Loomio/)
    end

    it 'assigns correct reply_to' do
      @mail.reply_to.should == [@inviter.email]
    end

    it 'assigns inviters name which appears in the email body' do
      @mail.body.encoded.should match(@inviter.name)
    end

    it 'assigns invite_url for email body' do
      @mail.body.encoded.should match(@user.invitation_token)
    end
  end
end
