module HasMentions
  extend ActiveSupport::Concern
  include Twitter::Extractor
  include HasEvents

  module ClassMethods
    def is_mentionable(on: [])
      define_singleton_method :mentionable_fields, -> { Array on }
    end
  end

  def mentioned_usernames
    extract_mentioned_screen_names(mentionable_text).uniq - [self.author.username]
  end

  def mentioned_user_ids
    Nokogiri::HTML(mentionable_text).search("span.mention[data-mention-id]").map do |el|
      el['data-mention-id']
    end.map(&:to_i)
  end

  def mentioned_users
     User.visible_by(author).where(mentioned_users_query)
  end

  def mentioned_users_query
    if text_format == "md"
      {username: mentioned_usernames}
    else
      {id: mentioned_user_ids}
    end
  end

  # users mentioned in the text, but not yet sent notifications
  def newly_mentioned_users
    mentioned_users
    .where.not(id: already_mentioned_users) # avoid re-mentioning users when editing
    .where.not(id: users_to_not_mention)
  end

  # users mentioned on a previous edit of this model
  def already_mentioned_users
    User.where(id: self.notifications.user_mentions.pluck(:user_id))
  end

  def users_to_not_mention
    User.none # overridden with specific users to not receive mentions
  end

  private

  def text_format
    self.send("#{self.class.mentionable_fields.first}_format")
  end

  def mentionable_text
    self.class.mentionable_fields.map { |field| self.send(field) }.join('|')
  end
end
