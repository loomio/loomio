require 'rails_helper'

describe Notification do
  before do
    @notification = Notification.new(:user => stub_model(User))
    @event = stub_model(Event)
    @notification.event = @event
    @notification.save!
  end

  subject { @notification }

  its(:event) { should eq(@event) }

  describe "#unviewed" do
    it "returns a scope of unviewed notifications" do
      Notification.unviewed.should include(@notification)
      @notification.viewed_at = Time.now
      @notification.save
      Notification.unviewed.should_not include(@notification)
    end
  end
end
