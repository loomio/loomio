require "rails_helper"

describe EventService do
  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { build :discussion, group: group, author: user }
  let(:poll) { create :poll, discussion: discussion }
  let(:comment1) { create(:comment, discussion: discussion, user: user) }
  let(:comment2) { create(:comment, discussion: discussion, user: user) }
  let(:comment3) { create(:comment, discussion: discussion, user: user) }

  before do
    group.add_admin! user
    group.add_admin! discussion.author
  end

  describe 'repair_thread' do
    let(:discussion) { build :discussion, max_depth: 2, group: group }
    let(:comment1) { create(:comment, body: 'comment1', discussion: discussion, user: user) }
    let(:comment2) { create(:comment, body: 'comment2', parent: comment1, discussion: discussion, user: user) }
    let(:comment3) { create(:comment, body: 'comment3', parent: comment2, discussion: discussion, user: user) }
    let!(:discussion_event) { DiscussionService.create(discussion: discussion, actor: discussion.author) }
    let!(:comment1_event) { CommentService.create(comment: comment1, actor: comment1.user) }
    let!(:comment2_event) { CommentService.create(comment: comment2, actor: comment2.user) }
    let!(:comment3_event) { CommentService.create(comment: comment3, actor: comment2.user) }

    let!(:poll) { create(:poll_proposal, discussion: discussion, group: discussion.group) }
    let!(:poll_created_event) { PollService.create(poll: poll, actor: discussion.author) }

    let!(:stance) do
      build(:stance, poll: poll, choice: "agree")
    end

    let!(:stance_created_event) do
      StanceService.create(stance: stance, actor: user)
    end


    it 'flattens' do
      discussion.update(max_depth: 1)
      EventService.repair_thread(discussion.id)
      [comment1_event, comment2_event, comment3_event, poll_created_event, stance_created_event].each(&:reload)
      expect(comment1_event.depth).to eq 1
      expect(comment2_event.depth).to eq 1
      expect(comment3_event.depth).to eq 1
      expect(comment1_event.parent.id).to eq discussion_event.id
      expect(comment2_event.parent.id).to eq discussion_event.id
      expect(comment3_event.parent.id).to eq discussion_event.id
      expect(poll_created_event.parent.id).to eq discussion_event.id
      expect(stance_created_event.parent.id).to eq discussion_event.id
    end

    it 'branches max_depth 2' do
      discussion.update(max_depth: 2)
      EventService.repair_thread(discussion.id)
      [comment1_event, comment2_event, comment3_event, poll_created_event, stance_created_event].each(&:reload)
      expect(comment1_event.depth).to eq 1
      expect(comment2_event.depth).to eq 2
      expect(comment3_event.depth).to eq 2
      expect(comment1_event.reload.parent.id).to eq discussion_event.id
      expect(comment2_event.reload.parent.id).to eq comment1_event.id
      expect(comment3_event.reload.parent.id).to eq comment1_event.id
      expect(poll_created_event.parent.id).to eq discussion_event.id
      expect(stance_created_event.parent.id).to eq poll_created_event.id
    end

    it 'branches max_depth 3' do
      discussion.update(max_depth: 3)
      EventService.repair_thread(discussion.id)
      [comment1_event, comment2_event, comment3_event, poll_created_event, stance_created_event].each(&:reload)
      expect(comment1_event.depth).to eq 1
      expect(comment2_event.depth).to eq 2
      expect(comment3_event.depth).to eq 3
      expect(comment1_event.reload.parent.id).to eq discussion_event.id
      expect(comment2_event.reload.parent.id).to eq comment1_event.id
      expect(comment3_event.reload.parent.id).to eq comment2_event.id
      expect(poll_created_event.parent.id).to eq discussion_event.id
      expect(stance_created_event.parent.id).to eq poll_created_event.id
    end
  end
end
