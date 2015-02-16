require 'rails_helper'

describe NotificationItems::MotionClosedByUser do
  let(:notification) { double(:notification) }
  let(:item) { NotificationItems::MotionClosedByUser.new(notification) }

  before do
    @closer = double(:user)
    notification.stub_chain(:event, :user).and_return(@closer)
    notification.stub_chain(:event, :eventable, :author).and_return(@closer)
  end

  context "user closed motion" do
    it "#action_text returns a string" do
      expect(item.action_text).to eq I18n.t('notifications.motion_closed.by_user')
    end
  end
end
