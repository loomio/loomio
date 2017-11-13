module HasMentions
  extend ActiveSupport::Concern
  include Twitter::Extractor

  included do
    has_many :notifications, through: :events

    def self.is_mentionable(on: [])
      define_singleton_method :mentionable_fields, -> { Array on }
    end
  end

  def mentionable
    self
  end

  def mentioned_group_members
    group.members.where(username: mentioned_usernames).without(users_to_not_mention)
  end

  # avoid re-mentioning users for this model
  def new_mentioned_group_members
    mentioned_group_members.without(group.members.mentioned_in(self))
  end

  def mentioned_usernames
    extract_mentioned_screen_names(mentionable_text).uniq - [self.author.username]
  end

  private

  def users_to_not_mention
    User.none # overridden with specific users to not receive mentions
  end

  def mentionable_text
    self.class.mentionable_fields.map { |field| self.send(field) }.join('|')
  end

end
