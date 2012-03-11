require "spec_helper"

describe GroupMailer do

  describe 'sends email on membership request' do
    group = Group.make!
    mail = GroupMailer.new_membership_request(group)

    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == "[Tautoko: #{group.name}] Membership waiting approval."
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ['noreply@tautoko.co.nz']
    end

    #ensure that the group name variable appears in the email body
    it 'assigns @group.name' do
      mail.body.encoded.should match(group.name)
    end

    #ensure that the confirmation_url appears in the email body
    it 'assigns url_for group' do
      mail.body.encoded.should match("http://localhost:3000/groups/#{group.id}")
    end
  end

  describe 'sends email on new motion creation' do
    group = Group.make!
    motion = create_motion(group: group)
    group_members = []
    motion.group.memberships.each do |m|
      group_members << m.user.email unless m.user.nil? or motion.author == m.user or m.access_level == 'request'
    end
    mail = GroupMailer.new_motion_created(motion)

    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == "[Tautoko: #{group.name}] New motion: #{motion.name}."
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ['noreply@tautoko.co.nz']
    end

    it 'sends email to group members but not author' do
      mail.to.should_not include(motion.author.email)
      mail.to.should == group_members
    end

    #ensure that the group name variable appears in the email body
    it 'assigns @group.name' do
      mail.body.encoded.should match(group.name)
    end

    #ensure that the confirmation_url appears in the email body
    it 'assigns url_for motion' do
      mail.body.encoded.should match("http://localhost:3000/motions/#{motion.id}")
    end
  end
end
