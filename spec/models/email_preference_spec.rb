require 'spec_helper'

describe EmailPreferences do
  let(:user) { stub_model(User) }
  let(:days_to_send) { ['Monday', 'Wednesday'] }

  before do
    @email_preferences = EmailPreferences.new(user: user)
  end

  describe "#all_memberships" do
    it 'calls group_memberships_for(user) on EmailPreferencesService' do
      EmailPreferencesService.should_receive(:group_memberships_for).with(user)
      @email_preferences.all_memberships
    end
  end

  describe "#group_email_preferences" do
    it 'calls group_notification_preferences_for(user) on EmailPreferencesService' do
      EmailPreferencesService.should_receive(:group_notification_preferences_for).with(user)
      @email_preferences.group_email_preferences
    end
  end

  describe "#subscribed_to_activity_summary_email?" do
    it 'returns true if next_activity_summary_sent_at is not nil' do
      @email_preferences.set_next_activity_summary_sent_at(Date.today + 2.days)
      @email_preferences.subscribed_to_activity_summary_email?.should be_true
    end
    it 'returns false if next_activity_summary_sent_at is nil' do
      @email_preferences.set_next_activity_summary_sent_at(nil)
      @email_preferences.subscribed_to_activity_summary_email?.should be_false
    end
  end

  describe "#set_next_activity_summary_sent_at(date_to_send)" do
    context 'date_to_send is a date' do
      it 'should set next_activity_summary_sent_at to the date_time created from date_to_send and hour_to_send' do
        @email_preferences.update_attribute(:hour_to_send, 10)
        @email_preferences.set_next_activity_summary_sent_at("14/01/2014")
        @email_preferences.next_activity_summary_sent_at.should == 'Tue, 14 Jan 2014 10:00:00 UTC +00:00'
      end
    end

    context 'date_to_send is nil' do
      it 'should set next_activity_summary_sent_at to nil' do
        @email_preferences.set_next_activity_summary_sent_at(nil)
        @email_preferences.next_activity_summary_sent_at.should be_nil
      end
    end    
  end

  describe '#unsubscribe_to_email_summary(email_preferences)' do
    before { @email_preferences.set_next_activity_summary_sent_at(Date.today + 2.days) }
    
    it 'sets the next_activity_summary_sent_at to nil' do
      @email_preferences.unsubscribe_to_email_summary
      @email_preferences.next_activity_summary_sent_at.should be_nil
    end
  end

  describe '#subscribe_to_email_summary' do
    it 'stores the next date in email_preferences' do
      next_date_to_send = @email_preferences.stub(:next_date_to_send)
      @email_preferences.stub(:set_next_activity_summary_sent_at).with(next_date_to_send)
      @email_preferences.should_receive(:set_next_activity_summary_sent_at)
      @email_preferences.subscribe_to_email_summary
    end
  end

  describe '#next_date_to_send' do
    before do
      @email_preferences.stub_chain(:days_to_send).and_return(["Sunday", "Monday", "Wednesday"])
      @email_preferences.stub(:next_dow_to_send).and_return(3)
    end

    it 'returns the date Wednesday if today is Tuesday' do
      Time.stub_chain(:now, :wday).and_return(2) # 'Tuesday'
      @email_preferences.next_date_to_send.should == Date.today + 1.day
    end

    it 'returns the date next Sunday if today is Thursday' do
      Time.stub_chain(:now, :wday).and_return(4) # 'Thursday'
      @email_preferences.next_date_to_send.should == Date.today + 3.days
    end

    it 'returns the date on Wednesday if today is Monday' do
      Time.stub_chain(:now, :wday).and_return(1) # 'Monday'
      @email_preferences.next_date_to_send.should == Date.today + 2.days
    end
  end

end