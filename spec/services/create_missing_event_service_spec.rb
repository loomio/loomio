require "rails_helper"

describe CreateMissingEventService do
  let(:user) { create :user }
  let(:group) { create :formal_group }
  let(:discussion) { create :discussion, group: group }
  let(:poll) { create :poll, discussion: discussion }
  let(:comment) { create(:comment, discussion: discussion, user: user) }
  let(:reply_comment) { create(:comment, discussion: discussion, user: user, parent: comment) }
  let(:stance) { create(:stance, poll: poll, participant: user) }
  let(:outcome) { create(:outcome, poll: poll, author: user) }

  before { group.add_admin! user }

  it "creates missing new_discussion events" do
    expect(Event.where(kind: "new_discussion", eventable: discussion).exists?).to be false
    event = discussion.created_event
    expect(event.eventable).to eq discussion
    # expect(event.created_at).to eq discussion.created_at
    expect(event.user).to eq discussion.author
    expect(event.parent_id).to be nil
    expect(event.depth).to be 0
  end

  it "fixes new_comment event depth and parent values" do
    res = Event.import [Event.new(kind: 'new_comment',
                                  discussion_id: comment.discussion.id,
                                  user_id: comment.author_id,
                                  eventable_id: comment.id,
                                  eventable_type: "Comment",
                                  parent_id: nil,
                                  depth: 0,
                                  sequence_id: 1,
                                  created_at: comment.created_at)]
    comment_event = Event.find res.ids.first.to_i
    expect(comment_event.parent_id).to be nil
    expect(comment_event.depth).to be 0

    res = Event.import [Event.new(kind: 'new_comment',
                                  discussion_id: reply_comment.discussion.id,
                                  user_id: reply_comment.author_id,
                                  eventable_id: reply_comment.id,
                                  eventable_type: "Comment",
                                  parent_id: nil,
                                  depth: 0,
                                  sequence_id: 2,
                                  created_at: reply_comment.created_at)]

    reply_comment_event = Event.find res.ids.first.to_i
    expect(reply_comment_event.parent_id).to be nil
    expect(reply_comment_event.depth).to be 0

    new_discussion_event = discussion.created_event

    comment_event.reload
    reply_comment_event.reload

    expect(comment_event.parent_id).to eq new_discussion_event.id
    expect(comment_event.depth).to eq 1
    expect(reply_comment_event.parent_id).to eq comment_event.id
    expect(reply_comment_event.depth).to eq 2

    # it should update the discussion ranges
    expect(RangeSet.includes? discussion.ranges, comment_event.sequence_id).to be true
    expect(RangeSet.includes? discussion.ranges, reply_comment_event.sequence_id).to be true
  end

  it "creates missing poll, stance, outcome created events" do
    expect(Event.where(kind: "poll_created", eventable: poll).exists?).to be false
    expect(Event.where(kind: "stance_created", eventable: stance).exists?).to be false
    expect(Event.where(kind: "outcome_created", eventable: outcome).exists?).to be false

    discussion.created_event

    poll_event = poll.created_event

    expect(poll_event.parent_id).to eq discussion.created_event.id
    expect(poll_event.depth).to eq 1
    expect(poll_event.sequence_id).to eq 1

    stance_event = stance.created_event
    expect(stance_event.parent_id).to eq poll_event.id
    expect(stance_event.depth).to eq 2
    expect(stance_event.discussion_id).to eq discussion.id
    expect(stance_event.sequence_id).to eq 2
    expect(stance_event.position).to be 1

    outcome_event = outcome.created_event
    expect(outcome_event.parent_id).to eq poll_event.id
    expect(outcome_event.depth).to eq 2
    expect(outcome_event.discussion_id).to eq discussion.id
    expect(outcome_event.sequence_id).to eq 3
    expect(outcome_event.position).to eq 2
    # create closed poll, stance, outcome
    # ensure created events are created for them
  end
end
