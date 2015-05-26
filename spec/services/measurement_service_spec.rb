require 'rails_helper'

describe MeasurementService do

  context 'take_daily_measurement' do
    let(:group) { create :group, cohort_id: 1 }
    let(:today) { Date.today }

    before do
      group
      member = create :user
      group.add_admin! member
      InvitationService.invite_to_group(group: group, recipient_emails: ['a@b.c'], inviter: member, message: 'hi')
      discussion = create :discussion, group: group, author: member
      motion = create :motion, discussion: discussion, author: member
      comment = create :comment, discussion: discussion, author: member
      CommentService.like(comment: comment, actor: member)
      create :group, parent: group

      member_visit = Visit.create(id: SecureRandom.uuid, user: member)
      VisitService.record(visit: member_visit, group: group, user: member)

      non_member = create :user
      non_member_visit = Visit.create(id: SecureRandom.uuid, user: non_member)
      VisitService.record(visit: non_member_visit, group: group, user: non_member)

      # pass tomorrow as period_end_on to include stuff that happened today
      #
      MeasurementService.measure_groups(today)
    end

    it "creates a snapshot for a group in a cohort" do
      measurement = GroupMeasurement.where(group_id: group.id).last
      measurement.group_id.should == group.id
      measurement.period_end_on.should == today
      (measurement.members_count > 0).should be true
      (measurement.admins_count > 0).should be true
      measurement.invitations_count.should == 1
      measurement.discussions_count.should == 1
      measurement.proposals_count.should == 1
      measurement.comments_count.should == 1
      measurement.likes_count.should == 1
      measurement.subgroups_count.should == 1
      measurement.group_visits_count.should == 2
      measurement.group_member_visits_count.should == 1
      measurement.organisation_visits_count.should == 2
      measurement.organisation_member_visits_count.should == 1
    end
  end
end
