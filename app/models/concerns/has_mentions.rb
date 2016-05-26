module HasMentions
  extend ActiveSupport::Concern
  include Twitter::Extractor

  module ClassMethods
    def is_mentionable(on: [])
      define_singleton_method :mentionable_fields, -> { Array on }
    end
  end

  def mentionable_text
    self.class.mentionable_fields.map { |field| self.send(field) }.join('|')
  end

  def mentioned_usernames
    extract_mentioned_screen_names(mentionable_text).uniq - [self.author.username]
  end

  def new_mentions_in(text)
    extract_mentioned_screen_names(text).uniq - [self.author.username] - mentioned_usernames
  end

  def mentioned_group_members
    group.users.where(username: mentioned_usernames)
  end
  # override if people notified is different from people mentioned
  alias :notified_group_members :mentioned_group_members

end
