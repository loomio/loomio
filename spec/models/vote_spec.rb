require 'rails_helper'

describe Vote do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create :discussion, group: group, author: user }
  let(:motion) { create(:motion, discussion: discussion) }

  context 'user votes' do
    let(:vote) { Vote.create(user: user, motion: motion, position: "no") }
    subject { vote }

    its(:age) { is_expected.to eq 0 }

    context 'user changes their position' do
      let(:vote2) { Vote.create(user: user, motion: motion, position: "yes") }
      before do
        vote
        vote2
      end

      subject { vote2 }
      its(:age) { is_expected.to eq 0 }

      it "should age the first vote" do
        vote.reload
        expect(vote.age).to eq 1
      end

      it 'the second vote should associate the first as the previous' do
        expect(vote2.previous_vote_id).to eq vote.id
      end

      context 'user changes their position again' do
        let(:vote3) { Vote.create(user: user, motion: motion, position: "no") }
        before do
          vote3
        end

        subject { vote3 }
        its(:age) { is_expected.to eq 0 }

        it "should age the first vote" do
          vote.reload
          expect(vote.age).to eq  2
        end

        it "should age the second vote" do
          vote2.reload
          expect(vote2.age).to eq  1
        end

        it 'the second vote should associate the first as the previous' do
          expect(vote3.previous_vote_id).to eq vote2.id
        end
      end
    end
  end

  it 'should only accept valid position values' do
    vote = build(:vote, position: 'bad', motion: motion)
    vote.valid?
    expect(vote).to have(1).errors_on(:position)
  end

  it 'can have a statement' do
    vote = Vote.new(position: "yes", statement: "This is what I think about the motion")
    vote.motion = motion
    vote.user = user
    expect(vote).to be_valid
  end

  it 'cannot have a statement over 250 chars' do
    vote = Vote.new(position: 'yes')
    vote.motion = create(:motion, discussion: discussion)
    vote.user = user
    vote.statement = "a"*251
    expect(vote).to_not be_valid
  end

  # it 'updates motion last_vote_at on create' do
  #   vote = Vote.new(position: "yes")
  #   vote.motion = motion
  #   vote.user = user
  #   vote.save!
  #   vote.reload
  #   motion.reload
  #   expect(motion.last_vote_at.to_s).to eq vote.created_at.to_s
  # end

  describe "previous_vote" do
    it "gets position from previous vote on same motion by same user
        (if any)" do
      vote = Vote.new(position: 'abstain')
      vote.motion = motion
      vote.user = user
      vote.save!

      vote2 = Vote.new(position: 'yes')
      vote2.motion = motion
      vote2.user = user
      vote2.save!

      expect(vote2.previous_vote.id).to eq vote.id
    end
  end
end
