require 'spec_helper_lite'
needs 'services'
require 'request_membership'

describe RequestMembership do
  let(:requestor) { double :user }
  let(:group) { double :group }
  let(:params) { { introduction: "Hi!" } }
  let(:args) { { params: params, group: group, requestor: requestor } }
  let(:membership_request) { double :membership_request }

  class MembershipRequest
  end
  
  module Events
    class MembershipRequested
    end
  end

  before do
    MembershipRequest.stub(:new).and_return(membership_request)
    membership_request.stub(:group=)
    membership_request.stub(:requestor=)
    membership_request.stub(:save).and_return(true)
    Events::MembershipRequested.stub(:publish!)
  end

  describe ".to_group(params: nil, group: nil, requestor: nil)" do
    it "builds a membership request from params" do
      MembershipRequest.should_receive(:new).with(params).
        and_return(membership_request)
      RequestMembership.to_group(args)
    end

    it "assigns group and requestor to the membership request" do
      membership_request.should_receive(:group=).with(group)
      membership_request.should_receive(:requestor=).with(requestor)
      RequestMembership.to_group(args)
    end

    it "saves the membership request" do
      membership_request.should_receive(:save)
      RequestMembership.to_group(args)
    end

    it "fires a MembershipRequested event" do
      Events::MembershipRequested.should_receive(:publish!).
        with(membership_request)
      RequestMembership.to_group(args)
    end

    it "returns the saved membership request" do
      RequestMembership.to_group(args).should eq(membership_request)
    end

    context "if the MembershipRequest cannot save" do
      before { membership_request.stub(:save).and_return(false) }

      it "does not fire an event" do
        Events::MembershipRequested.should_not_receive(:publish!)
        RequestMembership.to_group(args)
      end

      it "returns the unsaved membership request" do
        RequestMembership.to_group(args).should eq(membership_request)
      end
    end
  end
end
