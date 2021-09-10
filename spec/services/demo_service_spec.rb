require 'rails_helper'

include Dev::FakeDataHelper

describe 'DemoService' do
  let(:actor) { saved fake_user }
  let(:group) { saved(fake_group) }
  let(:author) { saved(fake_user) }
  let(:poll) { fake_poll(group: group, discussion: discussion) }
  let(:discussion) { fake_discussion(author: author, group: group) }
  let(:stance) { fake_stance(poll: poll, participant: author) }
  let(:outcome) { fake_outcome(poll: poll, author: author) }
  let(:new_discussion_event) { fake_new_discussion_event(discussion) }
  let(:poll_created_event) { fake_poll_created_event(poll) }
  let(:stance_created_event) { fake_stance_created_event(stance) }
  let(:outcome_created_event) { fake_outcome_created_event(outcome) }

  describe 'clone_group' do
    before do
      group.add_admin! author
      new_discussion_event.save!
      poll_created_event.save!
      stance_created_event.save!
      outcome_created_event.save!
    end

    it 'creates a new group' do
      clone = DemoService.create_clone_group_for_actor(group, actor)

      %w[
        name
        description
        description_format
        members_can_add_members
        members_can_edit_discussions
        members_can_edit_comments
        members_can_raise_motions
        members_can_vote
        members_can_start_discussions
        members_can_create_subgroups
        members_can_announce
        new_threads_max_depth
        new_threads_newest_first
        admins_can_edit_user_content
        members_can_add_guests
        members_can_delete_comments
        link_previews
      ].each do |field|
        expect(clone.send(field)).to eq group.send(field)
      end


      expect(clone.id).to be_present
      expect(clone.handle).to be nil
      expect(clone.creator_id).to eq actor.id
      expect(clone.is_visible_to_public).to be false
      expect(clone.is_visible_to_parent_members).to be false
      expect(clone.discussion_privacy_options).to eq 'private_only'
      expect(clone.membership_granted_upon).to eq 'approval'
      expect(clone.listed_in_explore).to be false
      expect(clone.secret_token.present?).to be true
      expect(clone.secret_token).not_to eq group.secret_token

      # check that the group has copied the tags
      expect(clone.tags.map(&:id)).not_to eq group.tags.map(&:id)
      expect(clone.tags.map(&:name)).to eq group.tags.map(&:name)

      expect(clone.subscription.plan).to eq 'demo'

      expect(clone.creator).to eq actor

      expect(clone.discussions.count).to eq group.discussions.count
      expect(clone.polls.count).to eq group.polls.count
      expect(clone.memberships.count).to eq group.memberships.count
    end

    it 'creates a clone discussion' do
      clone = DemoService.new_clone_discussion(discussion)
      clone.save!
      clone.reload
      expect(clone.title).to eq discussion.title
      expect(clone.description).to eq discussion.description
      expect(clone.description_format).to eq discussion.description_format
      expect(clone.items.count).to eq discussion.items.count
      expect(clone.comments.count).to eq discussion.comments.count
      expect(clone.polls.count).to eq discussion.polls.count
    end

    it 'creates a clone poll' do
      clone = DemoService.new_clone_poll(poll)
      clone.save!
      clone.reload
      expect(clone.title).to eq poll.title
      expect(clone.details).to eq poll.details
      expect(clone.details_format).to eq poll.details_format

      expect(clone.poll_options.count).to eq poll.poll_options.count
      expect(clone.poll_options.first.name).to eq poll.poll_options.first.name

      expect(clone.stances.count).to eq 1
      expect(clone.stances.first.participant_id).to eq poll.stances.first.participant_id
      expect(clone.stances.first.stance_choices.count).to eq poll.stances.first.stance_choices.count
      expect(clone.stances.first.stance_choices.first.score).to eq poll.stances.first.stance_choices.first.score

      expect(clone.outcomes.count).to eq 1
      expect(clone.outcomes.first.statement).to eq poll.outcomes.first.statement
    end
  end
end
