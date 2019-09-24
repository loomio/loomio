require 'rails_helper'

describe GroupExportService do
  let!(:group)            { create :formal_group }
  let!(:subgroup)         { create :formal_group, parent: group }
  let!(:another_group)    { create :formal_group }
  let!(:user)             { create :user }
  let!(:another_user)     { create :user }
  let!(:discussion)       { create :discussion, group: group }
  let!(:sub_discussion)   { create :discussion, group: subgroup }
  let!(:poll)             { create :poll, group: group }
  let!(:sub_poll)         { create :poll, group: subgroup }
  let!(:discussion_poll)  { create :poll, discussion: discussion, group: group }
  let!(:comment)          { create :comment, discussion: discussion }
  let!(:sub_comment)      { create :comment, discussion: sub_discussion }
  let!(:group_doc)        { create :document, model: group }
  let!(:discussion_doc)   { create :document, model: discussion }
  let!(:poll_doc)         { create :document, model: poll }
  let!(:comment_doc)      { create :document, model: comment }
  let!(:reader)           { create :discussion_reader, discussion: discussion, user: another_user }
  let!(:discussion_event) { DiscussionService.create(discussion: discussion, actor: discussion.author) }
  let!(:notification)     { discussion_event.notifications.create!(user: another_user, url: 'test.com') }
  let!(:discussion_reaction) { create :reaction, reactable: discussion }
  let!(:poll_reaction)       { create :reaction, reactable: poll }
  let!(:comment_reaction)    { create :reaction, reactable: comment }

  before do
    group.add_admin! user
    subgroup.add_member! user
    group.add_member! another_user
    @email_api_key = user.email_api_key
    [discussion, sub_discussion].each {|d| DiscussionService.create(discussion: d, actor: d.author)}
    PollService.create(poll: poll, actor: user)
    PollService.create(poll: sub_poll, actor: user)
    PollService.create(poll: discussion_poll, actor: user)
    [comment, sub_comment].each {|c| CommentService.create(comment: c, actor: c.author)}
  end

  describe 'export and import' do
    it 'can export a group' do
      filename = GroupExportService.export(group.all_groups, group.name)
      # puts "exported: #{filename}"
      [Group, Membership, User, Discussion, Comment, Poll, PollOption, Stance, StanceChoice,
       Reaction, Event, Notification, Document, DiscussionReader].each {|model| model.delete_all }
      # puts "importing: #{filename}"
      GroupExportService.import(filename)
      expect { another_group.reload }.to raise_error { ActiveRecord::RecordNotFound }
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
      expect(discussion_reaction.reload).to be_present
      expect(poll_reaction.reload).to be_present
      expect(comment_reaction.reload).to be_present
      expect(reader.reload).to be_present
      expect(discussion_event.reload).to be_present
      expect(notification.reload).to be_present
      expect(group.reload).to be_present
      expect(@email_api_key).to_not eq(user.email_api_key)
    end
  end
end
