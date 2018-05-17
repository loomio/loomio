module HasMentions
  extend ActiveSupport::Concern
  include Twitter::Extractor
  include HasEvents

  module ClassMethods
    def is_mentionable(on: [])
      define_singleton_method :mentionable_fields, -> { Array on }
    end
  end

  def mentioned_users
    User.active.verified.joins(:memberships).
      where('memberships.group_id': author.group_ids).
      where(username: mentioned_usernames)
  end

  def mentioned_usernames
    extract_mentioned_screen_names(mentionable_text).uniq - [self.author.username]
  end

  def users_to_not_mention
    User.none # overridden with specific users to not receive mentions
  end

  private

  def mentionable_text
    self.class.mentionable_fields.map { |field| self.send(field) }.join('|')
  end

end
