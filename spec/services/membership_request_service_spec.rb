require 'rails_helper'
#require_relative '../../app/services/membership_request_service'

#class MembershipRequest
#end

#module Events
  #class MembershipRequested
  #end
#end

describe MembershipRequestService do
  let(:ability) { double(:ability) }
  let(:user) { double(:user, ability: ability) }
  let(:membership_request) { double(:membership_request,
                                    requestor: user,
                                    save!: true) }

  after do
    MembershipRequestService.new(membership_request).perform!
  end

  context "authorized to request" do
    before do
      ability.should_receive(:can?).with(:create,
                                         membership_request).
                                    and_return(true)
    end

    it "fires a membership requested event" do
      Events::MembershipRequested.should_receive(:publish!).
                                  with(membership_request)
    end
  end

  context "not authorized to request" do
    before do
      ability.should_receive(:can?).
              with(:create, membership_request).
              and_return(false)
    end

    it "fires a membership requested event" do
      Events::MembershipRequested.should_not_receive(:publish!)
    end
  end
end
