require 'rails_helper'

describe 'VoteService' do

  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:motion) { create(:motion, discussion: discussion) }
  let(:vote) { build(:vote, motion: motion, author: user) }
  let(:user) { create(:user, email_on_participation: true) }
  let(:another_user) { create :user }
  let(:comment) { create :comment, discussion: discussion }
  let(:reader) { DiscussionReader.for(discussion: discussion, user: user) }

  describe 'create' do
    after do
      group.add_member! user
    end

    it 'authorizes the user can vote' do
      user.ability.should_receive(:authorize!).with(:create, vote)
      VoteService.create(vote: vote, actor: user)
    end

    it 'saves the vote' do
      vote.should_receive(:save!).and_return(true)
      VoteService.create(vote: vote, actor: user)
    end

    it 'clears out the draft' do
      draft = create(:draft, user: user, draftable: vote.motion, payload: { vote: { statement: 'statement draft' } })
      VoteService.create(vote: vote, actor: user)
      expect(draft.reload.payload['vote']).to be_blank
    end

    context 'vote is valid' do
      before do
        vote.stub(:valid?).and_return(true)
      end

      context 'vote position is yes' do
        it 'fires the NewVote event and returns it' do
          Events::NewVote.should_receive(:publish!).with(vote)
          VoteService.create(vote: vote, actor: user)
        end

        it 'ensures a discussion stays read' do
          group.add_member! another_user
          CommentService.create(comment: comment, actor: another_user)
          reader.viewed!(reader.discussion.last_activity_at)
          VoteService.create(vote: vote, actor: user)
          expect(reader.reload.last_read_sequence_id).to eq discussion.reload.last_sequence_id
        end

        it 'updates the discussion reader' do
          VoteService.create(vote: vote, actor: user)
          expect(reader.reload.participating).to eq true
          expect(reader.reload.volume.to_sym).to eq :loud
        end
      end
    end

    context 'vote invalid' do
      before do
        vote.stub(:valid?).and_return(false)
      end

      it 'fires no events' do
        Events::NewVote.should_not_receive(:publish!)
        VoteService.create(vote: vote, actor: user)
      end
    end
  end
end
