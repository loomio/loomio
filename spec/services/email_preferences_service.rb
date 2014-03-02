require 'spec_helper'
require_relative '../../app/services/email_preferences_service'

describe EmailPreferencesService do
  let(:user) { FactoryGirl.create(:user) }
  let(:group) { FactoryGirl.create(:group) }
  let(:days_to_send) { ['Monday', 'Wednesday'] }
  let(:email_preferences) { double(:email_preferences,
                                    user: user, 
                                    days_to_send: days_to_send, 
                                    update_attributes: true,
                                    next_activity_summary_sent_at: nil,
                                    :next_activity_summary_sent_at= => true,
                                    ) }
  def create_membership(options)
    result = Membership.new
    result.user = user
    result.group = options[:group] || group
    result.subscribed_to_notification_emails = options[:subscribed]
    result.access_level = 'member'
    result.save!
    result
  end

  def create_membership_for_new_group(name, options)
    other_group = FactoryGirl.create(:group, name: name)
    create_membership options.merge(group: other_group)
  end

  describe "#group_memberships_for(user)" do
    it "returns all memberships sorted by group name" do
      m1 = create_membership_for_new_group("Foo", subscribed: false)
      m2 = create_membership_for_new_group("Bar", subscribed: true)
      EmailPreferencesService.group_memberships_for(user).should == [m2, m1]
    end
  end

end