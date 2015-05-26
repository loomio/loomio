require 'rails_helper'

describe CohortService do
  context "tag_groups" do
    let(:other_group) { FactoryGirl.create :group, created_at: 1.month.ago }
    let(:group) { FactoryGirl.create :group }
    let(:cohort) { Cohort.create start_on: 1.week.ago.to_date, end_on: 1.week.from_now.to_date }

    before do
      group
      other_group
      cohort
      CohortService.tag_groups
    end

    it "tags all groups in the cohort timeframe with the cohort id" do
      group.reload.cohort.should == cohort
      other_group.cohort.should be nil
    end
  end

  context "avg_by_age_for" do
    # given two groups in cohort 1
    # group 1 starting on day one
    # group 2 starting on day two
    # group 1 at age 1 has 1 visit
    # group 2 at age 1 has 2 visits
    #
    # cohort 1, average visits at age 1 is 1.5
    let(:cohort) {Cohort.create(start_on: 2.weeks.ago, end_on: 1.week.from_now)}
    let(:group1_start_on) {1.day.ago.to_date}
    let(:group2_start_on) {2.days.ago.to_date }
    let(:group1) {create :group, created_at: group1_start_on, cohort_id: cohort.id }
    let(:group2) {create :group, created_at: group2_start_on, cohort_id: cohort.id }

    before do
      GroupMeasurement.create(group_id: group1.id,
                              age: 0,
                              period_end_on: group1_start_on,
                              organisation_member_visits_count: 1)

      GroupMeasurement.create(group_id: group2.id,
                              age: 0,
                              period_end_on: group2_start_on,
                              organisation_member_visits_count: 2)
    end

    it "gives the right value for avg" do
      result = CohortService.avg_by_age(cohort: cohort,
                                            measurement: 'organisation_member_visits')
      (result.to_hash[0]['avg']).to_f.should == 1.5
    end


  end
end
