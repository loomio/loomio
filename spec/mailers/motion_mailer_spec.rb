require "spec_helper"

describe MotionMailer do
  let(:user) { User.make! }
  let(:group) { Group.make! }
  let(:discussion) { create_discussion(group: group) }
  let(:motion) { create_motion(discussion: discussion) }

  describe 'sending email on new motion creation' do
    before(:all) do
      @email = MotionMailer.new_motion_created(motion, user.email)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @email.subject.should == "[Loomio: #{group.name}] New proposal - #{motion.name}"
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @email.from.should == ['noreply@loom.io']
    end

    it 'sends email to group members but not author' do
      @email.to.should == [user.email]
    end

    #ensure that the group name variable appears in the email body
    it 'assigns group.name' do
      @email.body.encoded.should match(group.name)
    end

    #ensure that the confirmation_url appears in the email body
    it 'assigns url_for motion' do
      @email.body.encoded.should match(discussion_url(discussion))
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
      @email.from.should == ['noreply@loom.io']
    end

    it 'sends to the motion author' do
      @email.to.should == [motion.author.email]
    end

    #ensure that the group name variable appears in the email body
    it 'assigns group.name' do
      @email.body.encoded.should match(group.name)
    end

    #ensure that the blocking user name appears in the email body
    it 'assigns group.name' do
      @email.body.encoded.should match(@vote.user.name)
    end

    #ensure that the discussion_url appears in the email body
    it 'assigns url_for motion' do
      @email.body.encoded.should match(/\/discussions\/#{motion.discussion.id}/)
    end
  end
end
