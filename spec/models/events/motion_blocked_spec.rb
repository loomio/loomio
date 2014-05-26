require 'spec_helper'

describe Events::MotionBlocked do
  let(:motion) { FactoryGirl.create :motion }
  let(:author) { FactoryGirl.create :user }
  let(:vote) { FactoryGirl.create :vote, motion: motion }

  describe "::publish!" do
    let(:event) { double(:event, :notify_users! => true) }

    before do
      Event.stub(:create!).and_return(event)
    end

    it 'creates an event' do
      Event.should_receive(:create!)
      Events::MotionBlocked.publish!(vote)
    end

    it 'returns an event' do
      Events::MotionBlocked.publish!(vote).should == event
    end
  end

  context "after event has been published" do
    let(:user) { FactoryGirl.create :user }
    let(:mailer) { double(:mailer, deliver: true) }
    let(:event) { Events::MotionBlocked.new(kind: "new_comment",
                                                  eventable: vote) }
    before do
      vote.stub(:other_group_members).and_return([user])
      vote.stub(:user).and_return(author)
    end

    it 'notifies other group members' do
      event.should_receive(:notify!).with(user)
      event.save
    end

    it 'emails motion blocked' do
      MotionMailer.should_receive(:motion_blocked).with(vote).and_return(mailer)
      event.save
    end
  end
end
