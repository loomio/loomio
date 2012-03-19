require "spec_helper"

describe MotionMailer do
  let(:user) { User.make! }
  let(:group) { Group.make! }
  let(:motion) { create_motion(group: group) }

  describe 'sending email on new motion creation' do
    before(:all) do
      @email = MotionMailer.new_motion_created(motion, user.email)
      #@email_addresses = []
      #group.users.each do |user|
        #@email_addresses << user.email unless motion.author == user
      #end
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @email.subject.should == "[Loomio: #{group.name}] New motion"
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
      @email.body.encoded.should match(/\/motions\/#{motion.id}/)
    end
  end

  describe 'sending email when motion is blocked' do
    before(:all) do
      @vote = Vote.create(motion: motion, user: user, position: "block")
      @email = MotionMailer.motion_blocked(@vote)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @email.subject.should match(/Motion has been blocked/)
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

    #ensure that the motion_url appears in the email body
    it 'assigns url_for motion' do
      @email.body.encoded.should match(/\/motions\/#{motion.id}/)
    end
  end
end
