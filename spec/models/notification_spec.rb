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

  describe "#unviewed" do
    it "returns a scope of unviewed notifications" do
      Notification.unviewed.should include(@notification)
      @notification.viewed_at = Time.now
      @notification.save
      Notification.unviewed.should_not include(@notification)
    end
  end
  describe "for a new discussion" do
    before do
      @user = stub_model(User)
      @discussion =  stub_model(Discussion, :author => @user)
      @event = stub_model(Event, :eventable => @discussion,
                          :eventable_type => "Discussion")
      @notification.event = @event
      @notification.save!
    end

    its(:discussion) { should eq(@discussion) }
  end

  describe "for new comment" do
    before do
      @comment = stub_model(Comment)
      @event = stub_model(Event, :eventable => @comment,
                          :eventable_type => "Comment")
      @notification.event = @event
      @notification.save!
    end

    its(:comment) { should eq(@comment) }
  end

  describe "for new motion" do
    before do
      @motion = stub_model(Motion)
      @event = stub_model(Event, :eventable => @motion,
                          :eventable_type => "Motion")
      @notification.event = @event
      @notification.save!
    end

    its(:motion) { should eq(@motion) }
  end

  describe "for new vote" do
    before do
      @vote = stub_model(Vote)
      @event = stub_model(Event, :eventable => @vote,
                          :eventable_type => "Vote")
      @notification.event = @event
      @notification.save!
    end

    its(:vote) { should eq(@vote) }
  end

  describe "for membership request" do
    before do
      @membership = stub_model(Membership)
      @event = stub_model(Event, :eventable => @membership,
                          :eventable_type => "Membership")
      @notification.event = @event
      @notification.save!
    end

    its(:membership) { should eq(@membership) }
  end

  describe "for comment vote" do
    before do
      @comment_vote = stub_model(CommentVote)
      @event = stub_model(Event, :eventable => @comment_vote,
                          :eventable_type => "CommentVote")
      @notification.event = @event
      @notification.save!
    end

    its(:comment_vote) { should eq(@comment_vote) }
  end
end
