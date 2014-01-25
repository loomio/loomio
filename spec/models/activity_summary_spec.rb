require 'spec_helper'

describe ActivitySummary do

  describe '.initialize(user, last_sent_at)' do
    let(:user) { create(:user) }
    let(:limit) { ActivitySummary::MAX_DAYS_OF_ACTIVITY.days.ago }

    it 'creates a new activity_sumary object' do
      activity_summary = ActivitySummary.new(user, 2.days.ago)
      activity_summary.should_not be_nil
    end
    it 'assigns user' do
      activity_summary = ActivitySummary.new(user, 2.days.ago)
      activity_summary.user.should == user
    end
    context 'last_sent_at is nil' do
      it 'sets last_sent_at to the MAX_DAYS_OF_ACTIVITY' do
        activity_summary = ActivitySummary.new(user, nil)
        activity_summary.last_sent_at.to_date.should == limit.to_date
      end
    end
    context 'last_sent_at is older than MAX_DAYS_OF_ACTIVITY' do
      it 'sets last_sent_at to the MAX_DAYS_OF_ACTIVITY' do
        activity_summary = ActivitySummary.new(user, 8.days.ago)
        activity_summary.last_sent_at.to_date.should == limit.to_date
      end
    end
    context 'last_sent_at is less than or equal to MAX_DAYS_OF_ACTIVITY ' do
      it 'sets last_sent_at to the MAX_DAYS_OF_ACTIVITY' do
        last_sent_at = 5.days.ago
        activity_summary = ActivitySummary.new(user, last_sent_at)
        activity_summary.last_sent_at.to_date.should == last_sent_at.to_date
      end
    end
  end

end