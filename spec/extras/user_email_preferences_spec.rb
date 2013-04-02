require 'spec_helper'

describe EmailPreferences do
  subject { EmailPreferences.new(user) }

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

  context "when fetching data" do
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }

    describe "#group_email_preferences" do
      it "returns an empty array if user has no memberships" do
        subject.group_email_preferences.should == []
      end

      it "returns the id of a membership which is subscribed to notifications" do
        membership = create_membership(subscribed: true)
        subject.group_email_preferences.should == [membership.id]
      end

      it "doesn't return the id of a membership which is not subscribed to notifications" do
        membership = create_membership(subscribed: false)
        subject.group_email_preferences.should == []
      end
    end

    describe "#all_memberships" do
      it "returns all memberships sorted by group name" do
        m1 = create_membership_for_new_group("Foo", subscribed: false)
        m2 = create_membership_for_new_group("Bar", subscribed: true)
        subject.all_memberships.should == [m2, m1]
      end
    end
  end
end