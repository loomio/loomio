require "rails_helper"

describe UserMailer do
  shared_examples_for 'email_meta' do
    it 'renders the receiver email' do
      expect(@mail.to).to eq [@user.email]
    end

    it 'renders the sender email' do
      expect(@mail.from).to include 'notifications@loomio.example.org'
    end
  end

  context 'sending email on membership approval' do
    before :each do
      @user = create(:user)
      @group = create(:group)
      @mail = UserMailer.group_membership_approved(@user, @group)
    end

    it_behaves_like 'email_meta'

    it 'assigns correct reply_to' do
      expect(@mail.reply_to).to eq [@group.admin_email]
    end

    it 'renders the subject' do
      expect(@mail.subject).to eq "[Loomio: #{@group.full_name}] Membership approved"
    end

    it 'assigns confirmation_url for email body' do
      @mail.body.encoded.should match(@group.key)
    end

  end

  context 'sending email on being added to group' do
    before :each do
      @user = create(:user)
      @inviter = create(:user)
      @group = create(:group, full_name: "Group full name")
      @mail = UserMailer.added_to_group(user: @user, inviter: @inviter, group: @group)
    end

    it 'renders the subject' do
      expect(@mail.subject).to eq "#{@inviter.name} has added you to #{@group.full_name}"
    end

    it 'uses group.full_name in the email body' do
      expect(@mail.body.encoded).to  include @group.full_name
    end
  end

end
