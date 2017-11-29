require "rails_helper"

describe EventService do
  let(:user) { create :user }
  let(:group) { create :formal_group }
  let(:discussion) { build :discussion, group: group }
  let(:poll) { create :poll, discussion: discussion }
  let(:comment1) { create(:comment, discussion: discussion, user: user) }
  let(:comment2) { create(:comment, discussion: discussion, user: user) }
  let(:comment3) { create(:comment, discussion: discussion, user: user) }

  before { group.add_admin! user }

  describe "migrate motion events" do
    let(:discussion) { create :discussion }
    let(:poll)             { create :poll, discussion: discussion, created_at: DateTime.parse("2000-01-01") }
    let(:stance)           { create :stance, poll: poll, created_at: DateTime.parse("2000-01-02") }
    let(:new_motion_event) { Event.new(kind: "new_motion",
                                       discussion_id: discussion.id,
                                       sequence_id: 1,
                                       created_at: poll.created_at).tap{|e|e.save(validate:false)} }
    let(:new_vote_event) { Event.new(kind: "new_vote",
                                     discussion_id: discussion.id,
                                     sequence_id: 1,
                                     created_at: stance.created_at).tap{|e| e.save(validate:false)} }

    it "migrates new_motion events" do
      new_motion_event
      EventService.migrate_new_motion_events
      new_motion_event.reload
      expect(poll.created_event.id).to eq(new_motion_event.id)
      expect(new_motion_event.kind).to eq "poll_created"
      expect(new_motion_event.eventable).to eq(poll)
      expect(new_motion_event.user).to eq poll.author
    end

    it "migrates new_vote events" do
      new_vote_event
      EventService.migrate_new_vote_events
      new_vote_event.reload
      expect(stance.created_event.id).to eq(new_vote_event.id)
      expect(new_vote_event.kind).to eq "stance_created"
      expect(new_vote_event.user).to eq stance.author
      expect(new_vote_event.eventable).to eq stance
    end
  end

  describe "readd_to_thread" do
    it "increments if spot is taken" do
      @event1 = Event.create(kind: "new_comment",
                             eventable: comment1,
                             discussion_id: discussion.id,
                             user: user)

      @event2 = Event.create(kind: "new_comment",
                             eventable: comment2,
                             discussion_id: discussion.id,
                             user: user)

      @event3 = Event.create(kind: "new_comment",
                             eventable: comment3,
                             discussion_id: discussion.id,
                             user: user)

      @missing_event = Event.create(kind: "poll_expired",
                                    eventable: poll,
                                    discussion_id: nil,
                                    sequence_id: 2)

      expect(@event1.sequence_id).to eq 1
      expect(@event2.sequence_id).to eq 2
      expect(@event3.sequence_id).to eq 3
      expect(discussion.reload.ranges_string).to eq "1-3"

      EventService.readd_to_thread(kind: :poll_expired)

      expect(@event1.sequence_id).to eq 1
      expect(@missing_event.sequence_id).to eq 2
      expect(@missing_event.reload.discussion_id).to eq discussion.id
      expect(@event2.reload.sequence_id).to eq 3
      expect(@event3.reload.sequence_id).to eq 4
      expect(discussion.reload.ranges_string).to eq "1-4"
    end

    it "reintroduces if spot is available" do
      @event1 = Event.create(kind: "new_comment",
                             eventable: comment1,
                             discussion_id: discussion.id,
                             user: user)

      @event2 = Event.create(kind: "new_comment",
                             eventable: comment2,
                             discussion_id: discussion.id,
                             sequence_id: 3,
                             user: user)

      @event3 = Event.create(kind: "new_comment",
                             eventable: comment3,
                             discussion_id: discussion.id,
                             sequence_id: 4,
                             user: user)

      @missing_event = Event.create(kind: "poll_expired",
                                    eventable: poll,
                                    discussion_id: nil,
                                    sequence_id: 2)

      expect(@event1.sequence_id).to eq 1
      expect(@event2.sequence_id).to eq 3
      expect(@event3.sequence_id).to eq 4
      expect(discussion.reload.ranges_string).to eq "1-1,3-4"

      EventService.readd_to_thread(kind: :poll_expired)

      expect(@event1.sequence_id).to eq 1
      expect(@missing_event.sequence_id).to eq 2
      expect(@missing_event.reload.discussion_id).to eq discussion.id
      expect(@event2.reload.sequence_id).to eq 3
      expect(@event3.reload.sequence_id).to eq 4
      expect(discussion.reload.ranges_string).to eq "1-4"
    end
  end
end
