require 'spec_helper'

describe Notification do
  it { should belong_to(:event) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:event) }
  it { should validate_presence_of(:user) }

  # This test isn't working for some reason
  #it { should validate_uniqueness_of(:event).scoped_to(:user) }
  it "should validate uniqueness on event scoped to user" do
    user = mock_model(User)
    event = mock_model(Event)
    lambda {
      Notification.create!(:event => event, :user => user)
      Notification.create!(:event => event, :user => user)
    }.should raise_error(ActiveRecord::RecordInvalid, /has already been taken/)
    lambda {
      Notification.create!(:event => mock_model(Event), :user => user)
    }.should_not raise_error
    lambda {
      Notification.create!(:event => event, :user => mock_model(User))
    }.should_not raise_error
  end

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
