require "spec_helper"

describe GroupMailer do

  describe 'sends email on membership request' do
    before(:all) do
      @group = Group.make!
      @membership = @group.add_request!(User.make!)
      @mail = GroupMailer.new_membership_request(@membership)
    end

    #ensure that the subject is correct
    it 'renders the subject' do
      @mail.subject.should ==
        "[Loomio: #{@group.name}] New membership request from #{@membership.user.name}"
    end

    it "sends email to group admins" do
      @mail.to.should == @group.admins.map(&:email)
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      @mail.from.should == ['noreply@loom.io']
    end

    #ensure that the confirmation_url appears in the email body
    it 'assigns url_for group' do
      @mail.body.encoded.should match(/\/groups\/#{@group.id}/)
    end
  end

end
