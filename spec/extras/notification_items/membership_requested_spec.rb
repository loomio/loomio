require 'rails_helper'

# External dependencies
module I18n; end
module Routing; end
require 'active_support/core_ext/object/blank'
require 'active_support/concern'

module NotificationItems; end
require_relative '../../../app/models/concerns/avatar_initials'
require_relative '../../../app/models/logged_out_user'
require_relative '../../../extras/notification_item'
require_relative '../../../extras/notification_items/membership_requested'

describe NotificationItems::MembershipRequested do
  let(:notification) { double(:notification, eventable: membership_request) }
  let(:item) { NotificationItems::MembershipRequested.new(notification) }
  let(:membership_request) { double(:membership_request,
                                    group_name: "hello",
                                    group: group,
                                    requestor: requestor) }
  let(:group) { double(:group, id: 1) }
  let(:requestor) { double(:user) }

  it "#action_text returns locale text" do
    action_text = "blah"
    I18n.should_receive(:t).with('notifications.membership_requested').
      and_return(action_text)
    expect(item.action_text).to eq action_text
  end

  it "#title returns the groups name" do
    expect(item.title).to eq notification.eventable.group_name
  end

  it "#group_full_name returns the group name including a parent group if there is one" do
    expect(item.group_full_name).to eq notification.eventable.group_name
  end

  it "#link returns a path to the membersip requests for the requested group" do
    item.should_receive(:group_membership_requests_path).with(group).and_return("/groups/1/membership_requests")
    expect(item.link).to eq ("/groups/1/membership_requests")
  end

  describe "#actor" do
    it "returns the user who requested membership" do
      requestor = double(:user)
      expect(item.actor).to eq notification.eventable.requestor
    end

    context "if membership was requested by a visitor to the site" do
      before do
        @name = "Rob Gob"
        @email = "rob@eee.org"
        membership_request.stub(requestor: nil)
        membership_request.stub(name: @name)
        membership_request.stub(email: @email)
      end

      it "returns a visitor with a name and email" do
        expect(item.actor.class).to eq (LoggedOutUser)
        expect(item.actor.name).to eq (@name)
        expect(item.actor.email).to eq (@email)
      end
    end
  end
end
