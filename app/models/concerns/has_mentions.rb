module HasMentions
  extend ActiveSupport::Concern
  include Twitter::Extractor

  included { has_many :notifications, through: :events }

  module ClassMethods
    def is_mentionable(on: [])
      define_singleton_method :mentionable_fields, -> { Array on }
    end
  end

  def mentioned_group_members
    group.users.where(username: mentioned_usernames)
  end

  def mentioned_usernames
    extract_mentioned_screen_names(mentionable_text).uniq - [self.author.username]
  end

  def users_to_not_mention
    [] # overridden with specific users to not receive mentions
  end

  private

  def mentionable_text
    self.class.mentionable_fields.map { |field| self.send(field) }.join('|')
  end

end
