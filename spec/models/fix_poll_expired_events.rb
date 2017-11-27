require "rails_helper"

describe "reinsert poll_expired events" do
  it "reinserts" do

    @user = create(:user)
    @group = create(:formal_group)
    @group.add_admin! @user

    @discussion = build(:discussion, group: @group)
    @discussion_event = DiscussionService.create(discussion: @discussion, actor: @user)
    @comment1 = create(:comment, discussion: @discussion, user: @user)
    @event1   = Event.create(kind: "new_comment",
                             eventable: @comment1,
                             discussion_id: @discussion.id,
                             user: @user)

    @comment2 = create(:comment, discussion: @discussion, user: @user)
    @event2   = Event.create(kind: "new_comment",
                             eventable: @comment2,
                             discussion_id: @discussion.id,
                             user: @user)

    @poll            = create(:poll, discussion: @discussion)
    @missing_event   = Event.create(kind: "poll_expired", eventable: @poll,
                                    discussion_id: nil, sequence_id: 2)

    expect(@event1.sequence_id).to be 1
    expect(@event2.sequence_id).to be 2


    expect(@event1.sequence_id).to be 1
    expect(@missing_event.sequence_id).to be 2
    expect(@missing_event.discussion_id).to be @discussion.id
    expect(@event2.sequence_id).to be 3

    # expect(
    #

    # has 2 events
    # new_comment sid 1
    # new_comment sid 2
    # poll expired discusion_id nil, eventable poll, sequence_id 2

  end
end
