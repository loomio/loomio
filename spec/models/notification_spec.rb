require 'spec_helper'

describe Notification do
  it { should belong_to(:event) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:event) }
  it { should validate_presence_of(:user) }
  #it { should validate_uniqueness_of(:event).scoped_to(:user) }

  before do
    @notification = Notification.new(:user => stub_model(User))
    @event = stub_model(Event)
    @notification.event = @event
    @notification.save!
  end

  subject { @notification }

  its(:event) { should eq(@event) }

  describe "for a new discussion" do
    before do
      @discussion =  stub_model(Discussion)
      @event = stub_model(Event, :discussion => @discussion)
      @notification.event = @event
      @notification.save!
    end

    its(:discussion) { should eq(@discussion) }
  end

  describe "for new comment" do
    before do
      @comment = stub_model(Comment)
      @event = stub_model(Event, :comment => @comment)
      @notification.event = @event
      @notification.save!
    end

    its(:comment) { should eq(@comment) }
  end

  describe "for new motion" do
    before do
      @motion = stub_model(Motion)
      @event = stub_model(Event, :motion => @motion)
      @notification.event = @event
      @notification.save!
    end

    its(:motion) { should eq(@motion) }
  end
end
