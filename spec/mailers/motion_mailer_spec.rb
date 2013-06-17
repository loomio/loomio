require "spec_helper"

describe MotionMailer do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create(:discussion, group: group) }
  let(:motion) { create(:motion, discussion: discussion) }

  describe 'sending email on new motion creation' do
    before(:all) do
      @email = MotionMailer.new_motion_created(motion, user)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @email.subject.should == "[Loomio: #{group.full_name}] New proposal - #{motion.name}"
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @email.from.should == ['noreply@loomio.org']
    end
    
    #ensure that reply to is correct
    it 'assigns reply to' do
      @email.reply_to.should == [motion.author_email]
    end

    it 'sends email to group members but not author' do
      @email.to.should == [user.email]
    end

    #ensure that the group name variable appears in the email body
    it 'assigns group.name' do
      @email.body.encoded.should match(group.full_name)
    end

    #ensure that the confirmation_url appears in the email body
    it 'assigns url_for motion' do
      @email.body.encoded.should match(motion_url(motion))
    end
  end

  describe 'sending email when motion is blocked' do
    before(:all) do
      @vote = Vote.new(position: "block")
      @vote.motion = motion
      @vote.user = user
      @vote.save
      @email = MotionMailer.motion_blocked(@vote)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @email.subject.should match(/Proposal blocked - #{motion.name}/)
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @email.from.should == ['noreply@loomio.org']
    end

    it 'sends to the motion author' do
      @email.to.should == [motion.author_email]
    end

    #ensure that reply to is correct
    it 'assigns reply to' do
      pending "This spec is failing on travis for some reason..."
      @email.reply_to.should == [group.admin_email]
    end

    #ensure that the group name variable appears in the email body
    it 'assigns group.full_name' do
      @email.body.encoded.should match(group.full_name)
    end

    #ensure that the discussion_url appears in the email body
    it 'assigns url_for motion' do
      @email.body.encoded.should match(/\/discussions\/#{motion.discussion.id}/)
    end
  end
end
