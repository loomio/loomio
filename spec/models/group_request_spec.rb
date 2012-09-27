require 'spec_helper'

describe GroupRequest do
  describe "#approve!" do
    before do
      @group = mock_model(Group)
      @group.stub(:creator=)
      @group.stub(:save!)
      Group.stub(:new => @group)
      GroupMailer.stub(:new_group_invited_to_loomio)
      @group_request = create :group_request
    end

    it "creates a group with the group_request's attributes" do
      Group.should_receive(:new).with(
        :name => @group_request.name,
      ).and_return(@group)
      @group.should_receive(:creator=).with(@group_request.admin_email)
      @group.should_receive(:save)
      @group_request.approve!
    end

    it "sends an instructional email (with invite token) to the admin of the group" do
      GroupMailer.should_receive(:new_group_invited_to_loomio).
        with(@group_request.admin_email, @group_request.name)
        and_return(double("emailer").should_receive(:deliver))
      @group_request.approve!
    end
  end
end
