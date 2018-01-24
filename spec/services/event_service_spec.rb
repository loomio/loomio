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
