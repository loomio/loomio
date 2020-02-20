require "rails_helper"

describe EventService do
  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { build :discussion, group: group }
  let(:poll) { create :poll, discussion: discussion }
  let(:comment1) { create(:comment, discussion: discussion, user: user) }
  let(:comment2) { create(:comment, discussion: discussion, user: user) }
  let(:comment3) { create(:comment, discussion: discussion, user: user) }

  before { group.add_admin! user }

  describe 'rearrange_events' do
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

    let!(:stance) { create(:stance, poll: poll, choice: "agree") }
    let!(:stance_created_event) { StanceService.create(stance: stance, actor: discussion.author) }


    it 'flattens' do
      discussion.update(max_depth: 1)
      EventService.rearrange_events(discussion)
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
      EventService.rearrange_events(discussion)
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
      EventService.rearrange_events(discussion)
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

  # describe "readd_to_thread" do
  #   it "increments if spot is taken" do
  #     @event1 = Event.create(kind: "new_comment",
  #                            eventable: comment1,
  #                            discussion_id: discussion.id,
  #                            user: user)
  #
  #     @event2 = Event.create(kind: "new_comment",
  #                            eventable: comment2,
  #                            discussion_id: discussion.id,
  #                            user: user)
  #
  #     @event3 = Event.create(kind: "new_comment",
  #                            eventable: comment3,
  #                            discussion_id: discussion.id,
  #                            user: user)
  #
  #     @missing_event = Event.create(kind: "poll_expired",
  #                                   eventable: poll,
  #                                   discussion_id: nil,
  #                                   sequence_id: 2)
  #
  #     expect(@event1.sequence_id).to eq 1
  #     expect(@event2.sequence_id).to eq 2
  #     expect(@event3.sequence_id).to eq 3
  #     expect(discussion.reload.ranges_string).to eq "1-3"
  #
  #     EventService.readd_to_thread(kind: :poll_expired)
  #
  #     expect(@event1.sequence_id).to eq 1
  #     expect(@missing_event.sequence_id).to eq 2
  #     expect(@missing_event.reload.discussion_id).to eq discussion.id
  #     expect(@event2.reload.sequence_id).to eq 3
  #     expect(@event3.reload.sequence_id).to eq 4
  #     expect(discussion.reload.ranges_string).to eq "1-4"
  #   end
  #
  #   it "reintroduces if spot is available" do
  #     @event1 = Event.create(kind: "new_comment",
  #                            eventable: comment1,
  #                            discussion_id: discussion.id,
  #                            user: user)
  #
  #     @event2 = Event.create(kind: "new_comment",
  #                            eventable: comment2,
  #                            discussion_id: discussion.id,
  #                            sequence_id: 3,
  #                            user: user)
  #
  #     @event3 = Event.create(kind: "new_comment",
  #                            eventable: comment3,
  #                            discussion_id: discussion.id,
  #                            sequence_id: 4,
  #                            user: user)
  #
  #     @missing_event = Event.create(kind: "poll_expired",
  #                                   eventable: poll,
  #                                   discussion_id: nil,
  #                                   sequence_id: 2)
  #
  #     expect(@event1.sequence_id).to eq 1
  #     expect(@event2.sequence_id).to eq 3
  #     expect(@event3.sequence_id).to eq 4
  #     expect(discussion.reload.ranges_string).to eq "1-1,3-4"
  #
  #     EventService.readd_to_thread(kind: :poll_expired)
  #
  #     expect(@event1.sequence_id).to eq 1
  #     expect(@missing_event.sequence_id).to eq 2
  #     expect(@missing_event.reload.discussion_id).to eq discussion.id
  #     expect(@event2.reload.sequence_id).to eq 3
  #     expect(@event3.reload.sequence_id).to eq 4
  #     expect(discussion.reload.ranges_string).to eq "1-4"
  #   end
  # end

end
