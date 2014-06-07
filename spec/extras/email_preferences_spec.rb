require 'spec_helper'

describe EmailPreferences do
  subject { EmailPreferences.new(user) }

  def create_membership(options)
    result = Membership.new
    result.user = user
    result.group = options[:group] || group
    result.subscribed_to_notification_emails = options[:subscribed]
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

  context "when setting data" do
    describe "#update_attributes" do
      let(:user) { mock_model(User) }

      it "passes attributes on to user" do
        attributes = {'a' => 'b'}
        user.should_receive(:update_attributes).with(attributes)
        subject.update_attributes(attributes)
      end

      it "doesn't pass on group_email_preferences" do
        attributes = {'a' => 'b', 'group_email_preferences' => 'c'}
        subject.should_receive(:group_email_preferences=).with('c')
        user.should_receive(:update_attributes).with({'a' => 'b'})
        subject.update_attributes(attributes)
      end
    end

    describe "#group_email_preferences=" do
      let(:user) { FactoryGirl.create(:user) }

      it "does nothing if given nil" do
        m1 = create_membership_for_new_group("Foo", subscribed: true)
        subject.group_email_preferences = nil
        m1.reload.subscribed_to_notification_emails.should be_true
      end

      it "disables membership notification if id not included in array" do
        m1 = create_membership_for_new_group("Foo", subscribed: true)
        subject.group_email_preferences = ['9232']
        m1.reload.subscribed_to_notification_emails.should be_false
      end

      it "enables membership notification if id is included in array" do
        m1 = create_membership_for_new_group("Foo", subscribed: false)
        subject.group_email_preferences = [m1.id.to_s]
        m1.reload.subscribed_to_notification_emails.should be_true
      end

      it "both enables and disables as required" do
        m1 = create_membership_for_new_group("Foo", subscribed: false)
        m2 = create_membership_for_new_group("Bar", subscribed: true)
        subject.group_email_preferences = [m1.id.to_s]
        m1.reload.subscribed_to_notification_emails.should be_true
        m2.reload.subscribed_to_notification_emails.should be_false
      end
    end
  end
end
