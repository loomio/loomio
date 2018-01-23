require 'rails_helper'

describe CohortService do
  context "tag_groups" do
    let(:other_group) { FactoryBot.create :formal_group, created_at: 1.month.ago }
    let(:group) { FactoryBot.create :formal_group }
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
end
