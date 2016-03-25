require 'rails_helper'

describe Queries::UsersByVolumeQuery do
  let(:user_with_reader_volume_loud) { FactoryGirl.create :user }
  let(:user_with_membership_volume_loud) { FactoryGirl.create :user }
  let(:user_with_reader_volume_normal) { FactoryGirl.create :user }
  let(:user_with_membership_volume_normal) { FactoryGirl.create :user }
  let(:user_with_reader_volume_quiet) { FactoryGirl.create :user }
  let(:user_with_membership_volume_quiet) { FactoryGirl.create :user }
  let(:user_with_reader_volume_mute) { FactoryGirl.create :user }
  let(:user_with_membership_volume_mute) { FactoryGirl.create :user }

  let(:discussion) { FactoryGirl.create :discussion }

  before do
    discussion.group.add_member!(user_with_membership_volume_loud).set_volume! :loud
    discussion.group.add_member!(user_with_membership_volume_normal).set_volume! :normal
    discussion.group.add_member!(user_with_membership_volume_quiet).set_volume! :quiet
    discussion.group.add_member!(user_with_membership_volume_mute).set_volume! :mute

    discussion.group.add_member!(user_with_reader_volume_loud)
    discussion.group.add_member!(user_with_reader_volume_normal)
    discussion.group.add_member!(user_with_reader_volume_quiet)
    discussion.group.add_member!(user_with_reader_volume_mute)

    DiscussionReader.for(discussion: discussion, user: user_with_reader_volume_loud).set_volume! :loud
    DiscussionReader.for(discussion: discussion, user: user_with_reader_volume_normal).set_volume! :normal
    DiscussionReader.for(discussion: discussion, user: user_with_reader_volume_quiet).set_volume! :quiet
    DiscussionReader.for(discussion: discussion, user: user_with_reader_volume_mute).set_volume! :mute
  end

  it "loud" do
    users = Queries::UsersByVolumeQuery.loud(discussion)
    users.should     include user_with_reader_volume_loud
    users.should     include user_with_membership_volume_loud
    users.should_not include user_with_membership_volume_normal
    users.should_not include user_with_membership_volume_quiet
    users.should_not include user_with_membership_volume_mute
    users.should_not include user_with_reader_volume_normal
    users.should_not include user_with_reader_volume_quiet
    users.should_not include user_with_reader_volume_mute
  end

  it "normal or loud" do
    users = Queries::UsersByVolumeQuery.normal_or_loud(discussion)
    users.should     include user_with_reader_volume_loud
    users.should     include user_with_reader_volume_normal
    users.should     include user_with_membership_volume_loud
    users.should     include user_with_membership_volume_normal

    users.should_not include user_with_membership_volume_quiet
    users.should_not include user_with_membership_volume_mute
    users.should_not include user_with_reader_volume_quiet
    users.should_not include user_with_reader_volume_mute
  end

  it "mute" do
    users = Queries::UsersByVolumeQuery.mute(discussion)
    users.should     include user_with_membership_volume_mute
    users.should     include user_with_reader_volume_mute

    users.should_not include user_with_reader_volume_loud
    users.should_not include user_with_membership_volume_loud
    users.should_not include user_with_membership_volume_normal
    users.should_not include user_with_membership_volume_quiet
    users.should_not include user_with_reader_volume_normal
    users.should_not include user_with_reader_volume_quiet
  end
end
