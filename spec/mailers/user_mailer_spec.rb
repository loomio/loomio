require "rails_helper"

describe UserMailer do
  shared_examples_for 'email_meta' do
    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end

    it 'renders the sender email' do
      @mail.from.should == ['notifications@loomio.org']
    end
  end
  context 'sending email on membership approval' do
    before :each do
      @user = create(:user)
      @group = create(:group)
      @mail = UserMailer.group_membership_approved(@user, @group)
       #stub_request(:head, /www.gravatar.com/).
      #with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      #to_return(status: 200, body: "stubbed response", headers: {})

    end

    it_behaves_like 'email_meta'

    it 'assigns correct reply_to' do
      @mail.reply_to.should == [@group.admin_email]
    end

    it 'renders the subject' do
      @mail.subject.should == "[Loomio: #{@group.full_name}] Membership approved"
    end

    it 'assigns confirmation_url for email body' do
      @mail.body.encoded.should match("http://localhost:3000/g/#{@group.key}")
    end
  end

  describe 'sending email on new motion creation' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }
    let(:discussion) { create :discussion, group: group }
    let(:motion) { create(:motion, discussion: discussion) }

    before do
      @email = UserMailer.motion_created(motion, user)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @email.subject.should == "#{I18n.t(:proposal)}: #{motion.name} - #{group.name}"
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @email.from.should == ["notifications@loomio.org"]
    end

    #ensure that reply to is correct
    it 'assigns reply to' do
      @email.reply_to.should == [motion.author_email]
    end

    it 'sends email to group members but not author' do
      @email.to.should == [user.email]
    end

    #ensure that the confirmation_url appears in the email body
    it 'assigns url_for motion' do
      @email.body.encoded.should match(motion_url(motion))
    end
  end

  describe 'sending email when motion is blocked' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }
    let(:discussion) { create :discussion, group: group }
    let(:motion) { create(:motion, discussion: discussion) }

    before do
      @vote = Vote.new(position: "block")
      @vote.motion = motion
      @vote.user = user
      @vote.save
      @email = UserMailer.motion_blocked(@vote)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @email.subject.should match(/Proposal blocked - #{motion.name}/)
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @email.from.should == ['notifications@loomio.org']
    end

    it 'sends to the motion author' do
      @email.to.should == [motion.author_email]
    end

    ##ensure that reply to is correct
    #it 'assigns reply to' do
      #pending "This spec is failing on travis for some reason..."
      #@email.reply_to.should == [group.admin_email]
    #end

    #ensure that the group name variable appears in the email body
    it 'assigns group.full_name' do
      @email.body.encoded.should match(group.full_name)
    end

    #ensure that the discussion_url appears in the email body
    it 'assigns url_for motion' do
      @email.body.encoded.should match(/\/d\/#{motion.discussion.key}/)
    end
  end
end
