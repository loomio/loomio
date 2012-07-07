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
    }.should_not raise_error(ActiveRecord::RecordInvalid, /has already been taken/)
    lambda {
      Notification.create!(:event => event, :user => mock_model(User))
    }.should_not raise_error(ActiveRecord::RecordInvalid, /has already been taken/)
  end

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
      @user = stub_model(User)
      @discussion =  stub_model(Discussion, :author => @user)
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

  describe "for new vote" do
    before do
      @vote = stub_model(Vote)
      @event = stub_model(Event, :vote => @vote)
      @notification.event = @event
      @notification.save!
    end

    its(:vote) { should eq(@vote) }
  end

  describe "for membership request" do
    before do
      @membership = stub_model(Membership)
      @event = stub_model(Event, :membership => @membership)
      @notification.event = @event
      @notification.save!
    end

    its(:membership) { should eq(@membership) }
  end
end
