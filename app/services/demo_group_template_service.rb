class DemoGroupTemplateService
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

  def initialize(template_key:, user:)
    @template_key = template_key.to_s
    @user = user
  end

  # Provisioning intentionally creates a fresh group on every run. This preserves
  # completed votes and read notifications in earlier demos instead of silently
  # rewriting user activity when an operator requests another clean walkthrough.
  def create!
    raise ArgumentError, "user must be persisted" unless user&.persisted?

    template = load_template
    people = create_people!(template.fetch("people"))
    facilitator = people.fetch(template.fetch("facilitator"))
    group = create_group!(template)
    add_people!(group, people, template.fetch("people"), facilitator)

    discussions = create_discussions!(template.fetch("discussions"), group, people)
    create_comments!(template.fetch("comments", []), discussions, people)
    polls = create_polls!(template.fetch("polls"), group, people, discussions)
    notifications = create_notifications!(template.fetch("notifications"), people, discussions, polls)

    Result.new(group: group, discussions: discussions, polls: polls, notifications: notifications)
  end

  private

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
    File.open(path) do |file|
      person.uploaded_avatar.attach(io: file, filename: path.basename.to_s)
    end
    person.update!(avatar_kind: "uploaded")
  end

  def add_people!(group, people, definitions, facilitator)
    definitions.each do |definition|
      person = people.fetch(definition.fetch("key"))
      group.add_member!(person)
      group.memberships.find_by!(user: person).update!(title: definition.fetch("title"))
    end
    group.add_admin!(facilitator)
  end

  def create_group!(template)
    group = Group.new(
      name: template.fetch("name"),
      description: template.fetch("description"),
      description_format: "md",
      group_privacy: template.fetch("group_privacy"),
      membership_granted_upon: template.fetch("membership_granted_upon"),
      discussion_privacy_options: "private_only",
      creator: user,
      info: {
        "demo_group_template" => template_key,
        "demo_group_recipient_id" => user.id
      }
    )

    GroupService.create(group: group, actor: user, skip_authorize: true).tap do |created_group|
      raise ActiveRecord::RecordInvalid, created_group unless created_group.persisted?

      created_group.subscription.update!(plan: "demo", owner: user)
      attach_group_asset!(created_group.cover_photo, template.fetch("cover_photo"))
      attach_group_asset!(created_group.logo, template.fetch("logo"))
    end
  end

  def attach_group_asset!(attachment, relative_path)
    path = template_asset_path(relative_path)
    File.open(path) do |file|
      attachment.attach(io: file, filename: path.basename.to_s)
    end
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
          allow_concurrent_polls: true,
          title: definition.fetch("title"),
          description: definition.fetch("description"),
          description_format: "md"
        },
        actor: people.fetch(definition.fetch("actor"))
      )
      raise ActiveRecord::RecordInvalid, discussion unless discussion.persisted?
      attach_files!(discussion, definition.fetch("files", []))

      [ definition.fetch("key"), discussion ]
    end
  end

  def create_comments!(definitions, discussions, people)
    definitions.each do |definition|
      comment = Comment.new(
        parent: discussions.fetch(definition.fetch("discussion")),
        body: definition.fetch("body"),
        body_format: "md"
      )
      CommentService.create(comment: comment, actor: people.fetch(definition.fetch("actor")))
      raise ActiveRecord::RecordInvalid, comment unless comment.persisted?
    end
  end

  def attach_files!(discussion, relative_paths)
    relative_paths.each do |relative_path|
      path = template_asset_path(relative_path)
      File.open(path) do |file|
        blob = ActiveStorage::Blob.create_and_upload!(io: file, filename: path.basename.to_s)
        ActiveStorage::Attachment.create!(name: "files", record: discussion, blob: blob)
      end
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

      cast_votes!(poll, people, definition.fetch("votes"))
      close_poll!(poll, actor, definition) if definition.fetch("closed", false)
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

  def cast_votes!(poll, people, definitions)
    definitions.each do |definition|
      person = people.fetch(definition.fetch("person"))
      stance = poll.stances.undecided.find_by!(participant: person, latest: true)
      stance.choice = vote_choice(poll, definition)
      stance.reason = definition.fetch("reason")
      StanceService.create(stance: stance, actor: person)
    end
  end

  def vote_choice(poll, definition)
    return definition.fetch("choice") unless definition.key?("scores")

    scores = definition.fetch("scores")
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
      TopicReader.for(user: user, topic: topic).set_volume!(email: :quiet, push: :normal)

      notification = NotificationService.create!(
        kind: definition.fetch("kind"),
        subject: subject,
        actor: people.fetch(definition.fetch("actor")),
        recipient_user_ids: [ user.id ]
      )
      NotificationDeliveryRouter.for(notification).route!
      notification
    end
  end
end
