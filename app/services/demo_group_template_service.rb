class DemoGroupTemplateService
  require "digest"
  TEMPLATE_KEY_PATTERN = /\A[a-z0-9_-]+\z/
  TEMPLATE_ROOT = Rails.root.join("config", "demo_groups")
  POLL_CONFIGURATION_KEYS = %w[
    agree_target
    dots_per_person
    maximum_stance_choices
    meeting_duration
    minimum_stance_choices
    stv_method
    stv_quota
    stv_seats
  ].freeze

  Result = Data.define(:group, :discussions, :polls, :notifications)

  def self.create!(template_key:, user:)
    new(template_key: template_key, user: user).create!
  end

  def self.prepare!(template_key:)
    new(template_key: template_key, user: nil).prepare!
  end

  def self.template_digest(template_key)
    Digest::SHA256.file(TEMPLATE_ROOT.join("#{template_key}.yml")).hexdigest
  end

  # The source retains the YAML content and stable record IDs used by the
  # translation cache. Queue entries are clones with recipient state added later.
  def self.prepare_source!(template_key:)
    result = prepare!(template_key: template_key)
    group = result.group
    group.update!(info: group.info.merge(
      "demo_group_source" => true,
      "demo_group_queued" => false,
      "demo_group_digest" => template_digest(template_key)
    ))
    group
  end

  def self.prepare_clone!(source:)
    clone = RecordCloner.new(recorded_at: source.created_at).create_clone_group(source)
    source_ids = clone.info.fetch("source_record_ids")
    clone_ids = source_ids.to_h { |key, id| [ "#{key.split('-').first}-#{id}", key.split('-').last.to_i ] }
    references = source.info.fetch("demo_group_references")
    mapped = references.deep_dup
    mapped["discussions"] = references.fetch("discussions").transform_values { |id| clone_ids.fetch("Discussion-#{id}") }
    mapped["polls"] = references.fetch("polls").transform_values { |id| clone_ids.fetch("Poll-#{id}") }
    clone.update!(
      membership_granted_upon: source.membership_granted_upon,
      members_can_add_members: false,
      members_can_add_guests: false,
      subscription: Subscription.create!(plan: "demo", owner: source.creator),
      info: clone.info.merge(
        "demo_group_template" => source.info.fetch("demo_group_template"),
        "demo_group_digest" => source.info.fetch("demo_group_digest"),
        "demo_group_queued" => true,
        "demo_group_references" => mapped
      )
    )
    clone
  end

  def self.claim!(group:, user:)
    template_key = group.info.fetch("demo_group_template")
    new(template_key: template_key, user: user).claim!(group)
  end

  def self.route_notifications!(notifications)
    notifications.each { |notification| NotificationDeliveryRouter.for(notification).route! }
  end

  def initialize(template_key:, user:)
    @template_key = template_key.to_s
    @user = user
  end

  # Provisioning intentionally creates a fresh group on every run. This preserves
  # completed votes and read notifications in earlier demos instead of silently
  # rewriting user activity when an operator requests another clean walkthrough.
  def create!
    raise ArgumentError, "user must be persisted" unless user&.persisted?

    result = ApplicationRecord.transaction { create_records!(recipient: user) }
    self.class.route_notifications!(result.notifications)
    result
  end

  # Queue entries contain all expensive demo content but no recipient-specific
  # membership, topic readers, or notifications. The template facilitator owns
  # the group until it is atomically claimed by a user.
  def prepare!
    ApplicationRecord.transaction { create_records!(recipient: nil) }
  end

  # Claim all recipient-specific database state together. Notification delivery
  # is routed by the caller after this transaction commits.
  def claim!(group)
    raise ArgumentError, "user must be persisted" unless user&.persisted?

    ApplicationRecord.transaction do
      group.lock!
      raise ArgumentError, "demo group is not queued" unless group.info["demo_group_queued"]

      references = group.info.fetch("demo_group_references")
      people = load_references!(User, references.fetch("people"))
      discussions = load_references!(group.discussions, references.fetch("discussions"))
      polls = load_references!(group.polls, references.fetch("polls"))

      group.update!(
        creator: user,
        members_can_add_members: false,
        members_can_add_guests: false,
        info: group.info.merge(
          "demo_group_queued" => false,
          "demo_group_recipient_id" => user.id
        )
      )
      group.subscription.update!(owner: user)
      group.add_member!(user)
      PollService.group_members_added(group.id)
      notifications = create_notifications!(load_template.fetch("notifications"), people, discussions, polls)

      Result.new(group: group, discussions: discussions, polls: polls, notifications: notifications)
    end
  end

  private

  def create_records!(recipient:)
    template = load_template
    people = create_people!(template.fetch("people"))
    facilitator = people.fetch(template.fetch("facilitator"))
    group = create_group!(template, actor: recipient || facilitator, queued: recipient.nil?)
    add_people!(group, people, template.fetch("people"), facilitator)
    group.membership_for(recipient).update!(admin: false) if recipient
    create_tags!(group, template.fetch("tags", []))

    discussions = create_discussions!(template.fetch("discussions"), group, people)
    comments = template.fetch("comments", [])
    comments_by_key = {}
    create_comments!(comments.reject { |definition| definition["deferred"] }, discussions, people, comments_by_key)
    polls = create_polls!(template.fetch("polls"), group, people, discussions)
    create_poll_comments!(template.fetch("poll_comments", []), polls, people)
    revise_polls_and_votes!(template.fetch("polls"), polls, people)
    close_polls!(template.fetch("polls"), polls, people)
    create_comments!(comments.select { |definition| definition["deferred"] }, discussions, people, comments_by_key)
    store_references!(group, people: people, discussions: discussions, polls: polls)
    notifications = if recipient
      create_notifications!(template.fetch("notifications"), people, discussions, polls)
    else
      []
    end

    Result.new(group: group, discussions: discussions, polls: polls, notifications: notifications)
  end

  attr_reader :template_key, :user

  def load_template
    unless template_key.match?(TEMPLATE_KEY_PATTERN)
      raise ArgumentError, "invalid demo group template key"
    end

    path = TEMPLATE_ROOT.join("#{template_key}.yml")
    raise ArgumentError, "unknown demo group template: #{template_key}" unless path.file?

    YAML.safe_load_file(path, aliases: false)
  end

  def create_people!(definitions)
    definitions.to_h do |attributes|
      person = User.find_or_create_by!(email: attributes.fetch("email")) do |new_person|
        new_person.name = attributes.fetch("name")
        new_person.username = attributes.fetch("username")
        new_person.email_verified = true
        new_person.detected_locale = "en"
        new_person.experiences = { hideOnboarding: true }
      end
      attach_person_avatar!(person, attributes.fetch("avatar"))
      [ attributes.fetch("key"), person ]
    end
  end

  def attach_person_avatar!(person, relative_path)
    return if person.uploaded_avatar.attached?

    path = template_asset_path(relative_path)
    person.uploaded_avatar.attach(io: StringIO.new(path.binread), filename: path.basename.to_s)
    person.update!(avatar_kind: "uploaded")
  end

  def add_people!(group, people, definitions, facilitator)
    definitions.each do |definition|
      person = people.fetch(definition.fetch("key"))
      group.add_member!(person)
      group.memberships.find_by!(user: person).update!(title: definition["title"])
    end
    group.add_admin!(facilitator)
  end

  def create_tags!(group, names)
    names.each_with_index do |name, index|
      group.tags.create!(name: name, color: Tag::COLORS.fetch(index))
    end
  end

  def create_group!(template, actor:, queued:)
    group = Group.new(
      name: template.fetch("name"),
      description: template.fetch("description"),
      description_format: "md",
      group_privacy: template.fetch("group_privacy"),
      membership_granted_upon: template.fetch("membership_granted_upon"),
      discussion_privacy_options: "private_only",
      members_can_add_members: false,
      members_can_add_guests: false,
      creator: actor,
      subscription: Subscription.new(plan: "demo", owner: actor),
      info: {
        "demo_group_template" => template_key,
        "demo_group_queued" => queued,
        "demo_group_recipient_id" => user&.id
      }
    )

    GroupService.create(group: group, actor: actor, skip_authorize: true).tap do |created_group|
      raise ActiveRecord::RecordInvalid, created_group unless created_group.persisted?

      attach_group_asset!(created_group.cover_photo, template.fetch("cover_photo"))
      attach_group_asset!(created_group.logo, template.fetch("logo"))
    end
  end

  def store_references!(group, people:, discussions:, polls:)
    references = {
      "people" => people.transform_values(&:id),
      "discussions" => discussions.transform_values(&:id),
      "polls" => polls.transform_values(&:id)
    }
    group.update!(info: group.info.merge("demo_group_references" => references))
  end

  def load_references!(relation, references)
    records = relation.where(id: references.values).index_by(&:id)
    references.to_h { |key, id| [ key, records.fetch(id) ] }
  end

  def attach_group_asset!(attachment, relative_path)
    path = template_asset_path(relative_path)
    attachment.attach(io: StringIO.new(path.binread), filename: path.basename.to_s)
  end

  def template_asset_path(relative_path)
    path = Rails.root.join(relative_path).cleanpath
    unless path.to_s.start_with?(Rails.root.to_s + File::SEPARATOR) && path.file?
      raise ArgumentError, "invalid demo group asset path"
    end

    path
  end

  def create_discussions!(definitions, group, people)
    definitions.to_h do |definition|
      discussion = DiscussionService.create(
        params: {
          group_id: group.id,
          private: true,
          max_depth: 3,
          tags: definition.fetch("tags", []),
          allow_concurrent_polls: true,
          title: definition.fetch("title"),
          description: definition.fetch("description"),
          description_format: definition.fetch("description_format", "md")
        },
        actor: people.fetch(definition.fetch("actor"))
      )
      raise ActiveRecord::RecordInvalid, discussion unless discussion.persisted?
      attach_files!(discussion, definition.fetch("files", []))

      [ definition.fetch("key"), discussion ]
    end
  end

  def create_comments!(definitions, discussions, people, comments_by_key)
    definitions.each do |definition|
      parent = if definition["reply_to"]
        comments_by_key.fetch(definition.fetch("reply_to"))
      else
        discussions.fetch(definition.fetch("discussion"))
      end
      comment = Comment.new(
        parent: parent,
        body: definition.fetch("body"),
        body_format: "md"
      )
      CommentService.create(comment: comment, actor: people.fetch(definition.fetch("actor")))
      raise ActiveRecord::RecordInvalid, comment unless comment.persisted?
      comments_by_key[definition.fetch("key")] = comment if definition["key"]
      definition.fetch("reactions", []).each do |reaction|
        Reaction.create!(
          reactable: comment,
          user: people.fetch(reaction.fetch("person")),
          reaction: reaction.fetch("emoji")
        )
      end
    end
  end

  def attach_files!(discussion, relative_paths)
    relative_paths.each do |relative_path|
      path = template_asset_path(relative_path)
      blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new(path.binread), filename: path.basename.to_s)
      ActiveStorage::Attachment.create!(name: "files", record: discussion, blob: blob)
    end
    discussion.reload.save! if relative_paths.any?
  end

  def create_polls!(definitions, group, people, discussions)
    definitions.to_h do |definition|
      discussion = discussions.fetch(definition.fetch("discussion"))
      actor = people.fetch(definition.fetch("actor"))
      poll = PollService.create(
        params: {
          group_id: group.id,
          topic_id: discussion.topic_id,
          poll_type: definition.fetch("poll_type"),
          title: definition.fetch("title"),
          details: definition.fetch("details"),
          details_format: "md",
          poll_option_names: poll_option_names(definition),
          closing_at: definition.fetch("closing_in_days").days.from_now,
          notify_on_open: false
        }.merge(definition.slice(*POLL_CONFIGURATION_KEYS).symbolize_keys),
        actor: actor
      )
      raise ActiveRecord::RecordInvalid, poll unless poll.persisted?

      cast_votes!(poll, people, definition)
      [ definition.fetch("key"), poll ]
    end
  end

  def poll_option_names(definition)
    return definition.fetch("options") unless definition.key?("meeting_times")

    meeting_day = 1.week.from_now.beginning_of_day
    definition.fetch("meeting_times").map do |time|
      (meeting_day + time.fetch("day_offset").days + time.fetch("hour").hours).iso8601
    end
  end

  def cast_votes!(poll, people, definition)
    definition.fetch("votes").each do |vote|
      person = people.fetch(vote.fetch("person"))
      stance = poll.stances.undecided.find_by!(participant: person, latest: true)
      stance.choice = vote_choice(poll, vote, definition)
      stance.reason = vote.fetch("reason")
      StanceService.create(stance: stance, actor: person)
    end
  end

  def create_poll_comments!(definitions, polls, people)
    comments = {}
    definitions.each do |definition|
      poll = polls.fetch(definition.fetch("poll"))
      parent = if definition["reply_to"]
        comments.fetch(definition.fetch("reply_to"))
      else
        poll.stances.latest.find_by!(participant: people.fetch(definition.fetch("parent_vote_by")))
      end
      comment = Comment.new(parent: parent, body: definition.fetch("body"), body_format: "md")
      CommentService.create(comment: comment, actor: people.fetch(definition.fetch("actor")))
      raise ActiveRecord::RecordInvalid, comment unless comment.persisted?
      comments[definition.fetch("key")] = comment
    end
  end

  # Seed a visible change of mind only after the objection has replies. The
  # stance service then preserves the earlier vote as history instead of
  # replacing it, which lets demo visitors follow how the concern was resolved.
  def revise_polls_and_votes!(definitions, polls, people)
    definitions.each do |definition|
      poll = polls.fetch(definition.fetch("key"))
      if definition["revised_details"] || definition["revised_title"]
        PollService.update(
          poll: poll,
          params: {
            title: definition.fetch("revised_title", poll.title),
            details: definition.fetch("revised_details", poll.details)
          },
          actor: people.fetch(definition.fetch("actor"))
        )
      end
      definition.fetch("vote_changes", []).each do |change|
        person = people.fetch(change.fetch("person"))
        stance = poll.stances.latest.find_by!(participant: person)
        StanceService.update(
          stance: stance,
          params: { choice: vote_choice(poll, change, definition), reason: change.fetch("reason") },
          actor: person
        )
      end
    end
  end

  def close_polls!(definitions, polls, people)
    definitions.each do |definition|
      next unless definition.fetch("closed", false)

      close_poll!(polls.fetch(definition.fetch("key")), people.fetch(definition.fetch("actor")), definition)
    end
  end

  def vote_choice(poll, vote, definition)
    unless vote.key?("scores")
      choice = vote.fetch("choice")
      return choice if choice.is_a?(Hash)

      index = definition.fetch("options").index(choice)
      return index ? poll.poll_options.order(:priority).to_a.fetch(index).name : choice
    end

    scores = vote.fetch("scores")
    raise ArgumentError, "meeting vote must score every option" unless scores.length == poll.poll_options.length

    poll.poll_options.zip(scores).to_h { |option, score| [ option.name, score ] }
  end

  def close_poll!(poll, actor, definition)
    PollService.close(poll: poll, actor: actor)
    return unless definition["outcome"]

    OutcomeService.create(
      outcome: Outcome.new(poll: poll, statement: definition.fetch("outcome"), statement_format: "md"),
      actor: actor
    )
  end

  # Route synchronously so the unread items exist as soon as the task returns.
  # Quiet email volume prevents demo provisioning from sending mail; normal push
  # volume still exercises registered browser and native notification channels.
  def create_notifications!(definitions, people, discussions, polls)
    definitions.map do |definition|
      subject = if definition.key?("discussion")
        discussions.fetch(definition.fetch("discussion")).created_topic_item
      else
        polls.fetch(definition.fetch("poll"))
      end
      topic = subject.topic
      TopicReader.find_or_create_for!(user: user, topic: topic).set_volume!(email: :quiet, push: :normal)

      notification = NotificationService.create!(
        kind: definition.fetch("kind"),
        subject: subject,
        actor: people.fetch(definition.fetch("actor")),
        recipient_user_ids: [ user.id ]
      )
      notification
    end
  end
end
