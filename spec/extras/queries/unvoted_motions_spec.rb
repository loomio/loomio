require 'spec_helper'

describe Queries::UnvotedMotions do
  let(:user) { create(:user) }
  let(:motion) { create(:motion, author: user) }
  let(:group) { motion.group }

  describe ".for(user, group)" do
    context 'there is an open motion in the group' do

      context "and user hasn't voted on it" do
        it "returns the motion" do
          Queries::UnvotedMotions.for(user, group).should include(motion)
        end
      end

      context "and user has voted on it" do
        it "doesn't returns the motion" do
          vote = Vote.new(position: 'yes')
          vote.motion = motion
          vote.user = user
          vote.save!
          Queries::UnvotedMotions.for(user, group).should_not include(motion)
        end
      end

      context "another user has voted on it" do
        it "returns the motion" do
          other_guy = create(:user)
          group.add_member!(other_guy)
          vote = Vote.new(position: 'yes')
          vote.motion = motion
          vote.user = other_guy
          vote.save!
          Queries::UnvotedMotions.for(user, group).should include(motion)
        end
      end
    end

    context 'there is a closed motion in the group' do
      it 'does not return the motion' do
        motion.close_motion!(user)
        Queries::UnvotedMotions.for(user, group).should_not include(motion)
      end
    end


  end
end
