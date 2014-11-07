require 'rails_helper'

describe 'VoteService' do
  before do
    Events::NewVote.stub(:publish!)
  end

  let(:vote) { double(:vote, position: 'yes', motion: motion, 'author=' => true, save!: true, valid?: true)}
  let(:ability) { double(:ability, :authorize! => true) }
  let(:user) { double(:user, ability: ability) }
  let(:motion) { double(:motion) }

  describe 'create' do
    after do
      VoteService.create(vote: vote, actor: user)
    end

    it 'authorizes the user can vote' do
      ability.should_receive(:authorize!).with(:create, vote)
    end

    it 'saves the vote' do
      vote.should_receive(:save!).and_return(true)
    end

    context 'vote is valid' do
      before do
        vote.stub(:valid?).and_return(true)
      end

      context 'vote position is yes' do
        it 'fires the NewVote event and returns it' do
          Events::NewVote.should_receive(:publish!).with(vote)
        end
      end
    end

    context 'vote invalid' do
      before do
        vote.stub(:valid?).and_return(false)
      end

      it 'fires no events' do
        Events::NewVote.should_not_receive(:publish!)
      end
    end
  end
end
