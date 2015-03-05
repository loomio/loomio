require 'rails_helper'

describe UsersByVolumeQuery do
  let(:user_with_reader_volume_email) { FactoryGirl.create :user }
  let(:user_with_membership_volume_email) { FactoryGirl.create :user }
  let(:user_with_volume_normal) { FactoryGirl.create :user }
  let(:user_with_reader_volume_mute) { FactoryGirl.create :user }
  let(:user_with_membership_volume_mute) { FactoryGirl.create :user }

  let(:discussion) { FactoryGirl.create :discussion }

  before do
    discussion.group.add_member! user_with_reader_volume_email
    DiscussionReader.for(discussion: discussion,
                         user: user_with_reader_volume_email).set_volume! :email

    discussion.group.add_member!(user_with_membership_volume_email).set_volume! :email

    discussion.group.add_member! user_with_volume_normal

    discussion.group.add_member! user_with_reader_volume_mute
    DiscussionReader.for(discussion: discussion,
                         user: user_with_reader_volume_mute).set_volume! :mute

    discussion.group.add_member!(user_with_membership_volume_mute).set_volume! :mute

  end

  context "email" do
    let(:users) { UsersByVolumeQuery.email(discussion) }

    it "includes user_with_reader_volume_email" do
      users.should include user_with_reader_volume_email
    end

    it "includes user_with_membership_volume_email" do
      users.should include user_with_membership_volume_email
    end

    it "does not include the others" do
      users.should_not include user_with_volume_normal,
                               user_with_reader_volume_mute,
                               user_with_membership_volume_mute
    end
  end

  context "normal" do
    let(:users) { UsersByVolumeQuery.normal(discussion) }

    it "includes user_with_volume_normal" do
      users.should include user_with_volume_normal
    end

    it "does not include the others" do
      users.should_not include user_with_reader_volume_email,
                               user_with_membership_volume_email,
                               user_with_reader_volume_mute,
                               user_with_membership_volume_mute
    end
  end

  context "mute" do
    let(:users) { UsersByVolumeQuery.mute(discussion) }

    it "includes user_with_reader_volume_mute" do
      users.should include user_with_reader_volume_mute
    end

    it "includes user_with_membership volume_mute" do
      users.should include user_with_membership_volume_mute
    end

    it "does not include the others" do
      users.should_not include user_with_reader_volume_email,
                               user_with_membership_volume_email,
                               user_with_volume_normal
    end
  end
end
