require "spec_helper"

describe GroupMailer do

  describe 'sends email on membership request' do
    before(:all) do
      @group = Group.make!
      membership = @group.add_request!(User.make!)
      @mail = GroupMailer.new_membership_request(membership)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @mail.subject.should == "[Loomio: #{@group.name}] Membership waiting approval"
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @mail.from.should == ['noreply@loom.io']
    end

    #ensure that the group name variable appears in the email body
    it 'assigns group.name' do
      @mail.body.encoded.should match(@group.name)
    end

    #ensure that the confirmation_url appears in the email body
    it 'assigns url_for group' do
      @mail.body.encoded.should match(/\/groups\/#{@group.id}/)
    end
  end

end
