require 'rails_helper'
include Dev::FakeDataHelper

describe MigrateUserService do
  let!(:patrick)            { saved fake_user(name: "Patrick Swayze") }
  let!(:jennifer)           { saved fake_user(name: "Jennifer Grey") }

  let!(:visit)              { Visit.create(user: patrick, id: SecureRandom.uuid) }
  let!(:group_visit)        { GroupVisit.create(group: group, user: patrick, visit: visit) }
  let!(:organisation_visit) { OrganisationVisit.create(organisation: group, user: patrick, visit: visit) }
  let!(:ahoy_message)       { Ahoy::Message.create(user: patrick) }
  let!(:ahoy_event)         { Ahoy::Event.create(id: SecureRandom.uuid, visit: visit, user: patrick) }

  let!(:group)              { saved fake_group(name: "Dirty Dancing Shoes") }
  let!(:another_group)      { saved fake_group(name: "another group") }
  let!(:discussion)         { saved fake_discussion(group: group) }
  let!(:discussion_reader)  { DiscussionReader.for(discussion: discussion, user: patrick) }
  let!(:patrick_comment)    { saved fake_comment(discussion: discussion) }
  let!(:jennifer_comment)   { saved fake_comment(discussion: discussion) }
  let!(:reaction)           { saved fake_reaction(reactable: patrick_comment, user: patrick) }
  let!(:poll)               { saved fake_poll(discussion: discussion) }
  let!(:outcome)            { saved fake_outcome(poll: poll) }
  let!(:patrick_stance)     { saved fake_stance(poll: poll) }
  let!(:jennifer_stance)    { saved fake_stance(poll: poll) }
  let!(:invitation)         { saved fake_invitation(inviter: patrick, group: group) }
  let!(:poll_invitation)    { saved fake_invitation(inviter: patrick, group: poll.guest_group, intent: :join_poll) }
  let!(:membership_request) { saved fake_membership_request(requestor: patrick, group: group) }
  let!(:identity)           { saved fake_identity(user: patrick) }
  let!(:draft)              { saved fake_draft(user: patrick, draftable: group) }
  let(:membership)          { group.memberships.find_by(user: jennifer) }
  let(:notification)        { patrick.notifications.last }
  let(:version)             { discussion.versions.last }
  let!(:another_membership) { another_group.add_admin! patrick }

  before do
    group.add_admin! patrick
    group.add_admin! jennifer

    DiscussionService.create(discussion: discussion, actor: patrick)
    DiscussionService.update(discussion: discussion, params: {title: "new version"}, actor: patrick)
    version.update(whodunnit: patrick.id)

    DiscussionReader.for(user: patrick, discussion: discussion)
    DiscussionReader.for(user: jennifer, discussion: discussion)

    CommentService.create(comment: patrick_comment, actor: patrick)
    CommentService.create(comment: jennifer_comment, actor: jennifer)
    PollService.create(poll: poll, actor: patrick)
    StanceService.create(stance: patrick_stance, actor: patrick)
    StanceService.create(stance: jennifer_stance, actor: jennifer)

    poll.update(closed_at: 1.day.ago)
    OutcomeService.create(outcome: outcome, actor: patrick)
    [patrick, jennifer].each {|u| u.update_attribute(:sign_in_count, 1) }
  end

  it 'updates user_id references from old to new' do
    expect {MigrateUserService.migrate!(source: patrick, destination: jennifer)}.to change {ActionMailer::Base.deliveries.count}.by(1)
    patrick.reload
    jennifer.reload

    assert_equal ahoy_event.reload.user, jennifer
    assert_equal ahoy_message.reload.user, jennifer
    assert_equal patrick_comment.reload.author, jennifer
    assert_equal invitation.reload.inviter, jennifer
    assert_equal group.reload.creator, jennifer
    assert_equal membership.reload.user, jennifer
    assert_equal reaction.reload.author, jennifer
    assert_equal poll.reload.author, jennifer
    assert_equal outcome.reload.author, jennifer
    assert_equal patrick_stance.reload.author, jennifer
    assert_equal patrick_stance.reload.latest, false
    assert_equal jennifer_stance.reload.author, jennifer
    assert_equal jennifer_stance.reload.latest, true
    assert_equal membership_request.reload.requestor, jennifer
    assert_equal identity.reload.user, jennifer
    assert_equal visit.reload.user, jennifer
    assert_equal group_visit.reload.user, jennifer
    assert_equal organisation_visit.reload.user, jennifer
    assert_equal DiscussionReader.find_by(discussion: discussion, user: jennifer).present?, true
    assert_equal DiscussionReader.count, 1
    assert_equal another_group.members.include?(jennifer), true
    assert_equal jennifer.memberships_count, 2

    assert_equal 1, poll.reload.stances_count
    assert_equal 1, group.reload.memberships_count
    assert_equal 1, group.reload.admin_memberships_count
    assert_equal version.reload.whodunnit, jennifer.id

    expect(patrick.reload.deactivated_at).to be_present
    expect(jennifer.reload.sign_in_count).to eq 2
  end
end
