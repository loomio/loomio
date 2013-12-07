require "spec_helper"

describe UserMailer do
  shared_examples_for 'email_meta' do
    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end

    it 'renders the sender email' do
      @mail.from.should == ['noreply@loomio.org']
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

  describe 'sending an activity summary email' do
    before(:all) do
      @user = create(:user)
      @since_time = 2.days.ago
      @mail = UserMailer.activity_summary(@user, @since_time)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @mail.subject.should match(/Loomio activity summary/)
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @mail.from.should == ['noreply@loomio.org']
    end
  end
end
