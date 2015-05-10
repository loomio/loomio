require 'rails_helper'

describe MeasurementService do

  context 'take_daily_measurement' do
    let(:group) { create :group, cohort_id: 1 }
    let(:today) { Date.today }

    before do
      group
      user = create :user
      group.add_admin! user
      InvitationService.invite_to_group(group: group, recipient_emails: ['a@b.c'], inviter: user, message: 'hi')
      discussion = create :discussion, group: group, author: user
      motion = create :motion, discussion: discussion, author: user
      comment = create :comment, discussion: discussion, author: user
      CommentService.like(comment: comment, actor: user)
      create :group, parent: group
      MeasurementService.measure_groups
    end

    it "creates a snapshot for a group in a cohort" do
      measurement = GroupMeasurement.where(group_id: group.id).last
      measurement.group_id.should == group.id
      measurement.measured_on.should == today
      (measurement.members_count > 0).should be true
      (measurement.admins_count > 0).should be true
      measurement.invitations_count.should == 1
      measurement.discussions_count.should == 1
      measurement.proposals_count.should == 1
      measurement.comments_count.should == 1
      measurement.likes_count.should == 1
      measurement.subgroups_count.should == 1
    end
  end
end
