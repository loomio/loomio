require 'rails_helper'

describe MigrateGroupService do
  let!(:group)            { create :formal_group }
  let!(:subgroup)         { create :formal_group, parent: group }
  let!(:another_group)    { create :formal_group }
  let!(:user)             { create :user }
  let!(:another_user)     { create :user }
  let!(:discussion)       { create :discussion, group: group }
  let!(:sub_discussion)   { create :discussion, group: subgroup }
  let!(:poll)             { create :poll, group: group }
  let!(:sub_poll)         { create :poll, group: subgroup }
  let!(:discussion_poll)  { create :poll, discussion: discussion }
  let!(:comment)          { create :comment, discussion: discussion }
  let!(:sub_comment)      { create :comment, discussion: sub_discussion }
  let!(:group_doc)        { create :document, model: group }
  let!(:discussion_doc)   { create :document, model: discussion }
  let!(:poll_doc)         { create :document, model: poll }
  let!(:comment_doc)      { create :document, model: comment }
  let!(:discussion_react) { create :reaction, reactable: discussion }
  let!(:poll_react)       { create :reaction, reactable: poll }
  let!(:comment_react)    { create :reaction, reactable: comment }
  let!(:reader)           { create :discussion_reader, discussion: discussion, user: another_user }
  let!(:event)            { discussion.created_event }
  let!(:notification)     { event.notifications.create!(user: another_user, url: 'test.com') }

  before do
    group.add_admin! user
    group.add_member! another_user
  end

  describe 'export' do
    it 'can export a group' do
      json = MigrateGroupService.export(group)
      expect(json['groups'].keys).to include group.id
      expect(json['groups'].keys).to include subgroup.id
      expect(json['discussions'].keys).to include discussion.id
      expect(json['discussions'].keys).to include sub_discussion.id
      expect(json['polls'].keys).to include poll.id
      expect(json['polls'].keys).to include sub_poll.id
      expect(json['polls'].keys).to include discussion_poll.id
      expect(json['comments'].keys).to include comment.id
      expect(json['comments'].keys).to include sub_comment.id
      expect(json['documents'].keys).to include group_doc.id
      expect(json['documents'].keys).to include discussion_doc.id
      expect(json['documents'].keys).to include poll_doc.id
      expect(json['documents'].keys).to include comment_doc.id
      expect(json['reactions'].keys).to include discussion_react.id
      expect(json['reactions'].keys).to include poll_react.id
      expect(json['reactions'].keys).to include comment_react.id
      expect(json['discussion_readers'].keys).to include reader.id
      expect(json['events'].keys).to include event.id
      expect(json['users'].keys).to include group.creator_id
      expect(json['users'].keys).to include user.id
      expect(json['users'].keys).to include another_user.id
      expect(json['users'].keys).to include discussion.author_id
      expect(json['users'].keys).to include poll.author_id
      expect(json['users'].keys).to include comment.author_id
      expect(json['users'].keys).to include discussion_react.user_id
      expect(json['events'].keys).to include event.id
      expect(json['notifications'].keys).to include notification.id
    end
  end

  describe 'import' do
    it 'can import a group from json' do
      json = MigrateGroupService.export(group)
      Group.destroy_all
      MigrateGroupService.import(json)
      expect { another_group.reload }.to raise_error { ActiveRecord::RecordNotFound }
      expect(group.reload).to be_present
      expect(subgroup.reload).to be_present
      expect(user.reload).to be_present
      expect(another_user.reload).to be_present
      expect(discussion.reload).to be_present
      expect(sub_discussion.reload).to be_present
      expect(poll.reload).to be_present
      expect(sub_poll.reload).to be_present
      expect(discussion_poll.reload).to be_present
      expect(comment.reload).to be_present
      expect(sub_comment.reload).to be_present
      expect(group_doc.reload).to be_present
      expect(discussion_doc.reload).to be_present
      expect(poll_doc.reload).to be_present
      expect(comment_doc.reload).to be_present
      expect(discussion_react.reload).to be_present
      expect(poll_react.reload).to be_present
      expect(comment_react.reload).to be_present
      expect(reader.reload).to be_present
      expect(event.reload).to be_present
      expect(notification.reload).to be_present
    end
  end
end
