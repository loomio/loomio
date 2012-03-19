require "spec_helper"

describe MotionMailer do
  let(:group) { Group.make! }
  let(:motion) { create_motion(group: group) }

  describe 'sends email on new motion creation' do
    before(:all) do
      @email = MotionMailer.new_motion_created(motion)
      @email_addresses = []
      group.users.each do |user|
        @email_addresses << user.email unless motion.author == user
      end
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @email.subject.should == "[Loomio: #{group.name}] New motion: #{motion.name}."
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @email.from.should == ['noreply@loom.io']
    end

    it 'sends email to group members but not author' do
      @email.to.should_not include(motion.author.email)
      @email.to.should == @email_addresses
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
end
