require_relative '../../app/services/email_preferences_service'

describe 'email_preferences_service' do
  let(:user) { double(:user) }
  let(:email_preferences) { double(:email_preferences,
                                    user: user, 
                                    days_to_send: ["Monday", "Wednesday"], 
                                    update_attributes: true,
                                    set_next_activity_summary_sent_at: nil
                                    ) }

  describe 'update_preferences(email_preferences, attributes)' do
    it 'updates the email_preferences' do
    end

    it 'updates the group_email_preferences' do
    end

    it 'subscribes the user for the activity summary if any day is selected' do
    end

    it 'unsubscribes the user for the activity summary if no days are selected' do
    end
  end

  describe 'subscribe_to_email_summary(email_preferences)' do
    it 'gets the current day of the week in users time'
    it 'gets the next day to send the summary from days_to_send'
    it 'calulates the difference from then to now'
    it 'sets the time the next summary will be sent'

    EmailPreferencesService.subscribe_to_email_summary(email_preferences)

  end
end