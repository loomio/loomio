require 'rails_helper'

describe NotificationItems::MotionClosed do
  let(:notification) { double(:notification) }
  let(:item) { NotificationItems::MotionClosed.new(notification) }

  before do
    @closer = double(:user)
    notification.stub_chain(:event, :user).and_return(@closer)
    notification.stub_chain(:event, :eventable, :author).and_return(@closer)
  end

  context "motion expired" do
    before { notification.stub_chain(:event, :user).and_return(nil) }

    it "#action_text returns a string" do
      expect(item.action_text).to eq I18n.t('notifications.motion_closed.by_expiry') + ": "
    end

    it "#avatar returns the motion author" do
      notification.stub_chain(:eventable, :author).and_return("Peter")
      expect(item.avatar).to eq notification.eventable.author
    end
  end

  it "#title returns the motion name" do
    notification.stub_chain(:eventable, :name).and_return("hello")
    expect(item.title).to eq notification.eventable.name
  end

  it "#group_full_name returns the discussion's group name including a parent if there is one" do
    notification.stub_chain(:eventable, :group_full_name).and_return("goob")
    expect(item.group_full_name).to eq notification.eventable.group_full_name
  end

  it "#link returns a path to the motion" do
    item.stub_chain(:url_helpers, :motion_path).and_return("/motions/1")
    notification.stub(:eventable).and_return(double(:motion))
    expect(item.link).to eq "/motions/1"
  end
end
