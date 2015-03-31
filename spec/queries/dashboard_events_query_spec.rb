require 'rails_helper'

describe DashboardEventsQuery do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:another_group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:another_discussion) { create :discussion, group: another_group }
  let(:muted_discussion) { create :discussion, group: group }
  let(:old_event) { CommentService.create(comment: build(:comment, discussion: discussion, created_at: 1.day.ago), actor: user) }
  let(:new_event) { CommentService.create(comment: build(:comment, discussion: discussion, created_at: 3.days.ago), actor: user) }
  let(:forbidden_event) { CommentService.create(comment: build(:comment, discussion: another_discussion), actor: another_user) }
  let(:muted_event) { CommentService.create(comment: build(:comment, discussion: muted_discussion), actor: user) }

  before do
    group.members << user
    another_group.members << another_user
    old_event; new_event; forbidden_event; muted_event
    DiscussionReader.for(user: user, discussion: muted_discussion).set_volume! :mute
    @query_ids = DashboardEventsQuery.latest_events_for(user).map(&:id)
  end

  it 'returns the latest events for a dashboard discussion' do
    expect(@query_ids).to include new_event.id
    expect(@query_ids).to_not include old_event.id
  end

  it 'does not return events the user does not have access to' do
    expect(@query_ids).to_not include forbidden_event.id
  end

  it 'does not return muted events' do
    expect(@query_ids).to_not include muted_event.id
  end

end
