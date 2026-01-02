require 'rails_helper'

describe Events::GroupMentioned do
  let(:group) { create :group, handle: 'testgroup' }
  let(:discussion) { create :discussion, group: group }
  let(:actor) { create :user }
  let(:volume_quiet_member) { create :user }
  let(:volume_normal_member) { create :user }
  let(:volume_loud_member) { create :user }
  let(:mentioned_member) { create :user, username: 'testuser' }
  let(:comment) do
    build :comment,
          discussion: discussion,
          author: actor,
          body: "hello @testgroup, how's it going? special mention @testuser",
          body_format: 'md'
  end

  before do
    [actor, volume_quiet_member, volume_normal_member, volume_loud_member, mentioned_member].each do |user|
      group.add_member!(user)
    end
    group.membership_for(volume_quiet_member).update(volume: :quiet)
    group.membership_for(volume_normal_member).update(volume: :normal)
    group.membership_for(volume_loud_member).update(volume: :loud)
  end

  it "does not notify people more than it should" do
    Events::NewComment.publish!(comment)
    expect(emails_sent_to(volume_quiet_member.email).size).to eq 0
    expect(emails_sent_to(volume_normal_member.email).size).to eq 1
    expect(emails_sent_to(volume_loud_member.email).size).to eq 1
    expect(emails_sent_to(mentioned_member.email).size).to eq 1
  end

  it "notifies normally" do
    expect { Events::NewComment.publish!(comment) }.to(change { Event.where(kind: 'group_mentioned').count }.by(1))
  end

  it "does not notify if members cannot notify group" do
    group.update(members_can_announce: false)
    expect { Events::NewComment.publish!(comment) }.to_not(change { Event.where(kind: 'group_mentioned').count })
  end

  it "notifies if members_cannot announce but user is an admin" do
    group.update(members_can_announce: false)
    group.add_admin! actor
    expect { Events::NewComment.publish!(comment) }.to(change { Event.where(kind: 'group_mentioned').count }.by(1))
  end

  it "notifies group on edit, newly mentioned" do
    comment.update(body: "no mentions in here")
    Events::NewComment.publish!(comment)
    expect(Event.where(kind: 'group_mentioned').count).to eq 0
    comment.update(body: "edited to mention group @testgroup")

    Events::CommentEdited.publish!(comment, comment.author)
    expect(Event.where(kind: 'group_mentioned').count).to eq 1
  end

  it "does not notify group on edit, exisiting mention" do
    Events::NewComment.publish!(comment)
    expect(Event.where(kind: 'group_mentioned').count).to eq 1

    comment.update(body: "edited to mention group @testgroup, although it was already mentioned")
    Events::CommentEdited.publish!(comment, comment.author)
    expect(Event.where(kind: 'group_mentioned').count).to eq 1
  end
end
