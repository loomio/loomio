require 'spec_helper'

describe Queries::Voters do
  let(:motion) { create(:motion) }
  let(:member) { create(:user) }
  let(:member2) { create(:user) }

  before do
    motion.group.add_member!(member)
    motion.group.add_member!(member2)
    vote = create(:vote, user: member, motion: motion)
  end

  describe "::users_that_voted_on(motion)" do
    it "yields users that voted on the motion" do
      users = Queries::Voters.users_that_voted_on(motion)
      users.should include(member)
      users.should_not include(member2)
    end
  end

  describe "::group_members_that_havent_voted_on(motion)" do
    it "yields motion group members that didnt vote on the motion" do
      non_member = create(:user)
      users = Queries::Voters.group_members_that_havent_voted_on(motion)
      users.should include(member2)
      users.should_not include(member)
      users.should_not include(non_member)
    end
  end
end
