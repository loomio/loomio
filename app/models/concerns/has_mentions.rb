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
    if text_format == "md"
      extract_mentioned_screen_names(mentionable_text).uniq - [self.author.username]
    else
      Nokogiri::HTML(mentionable_text).search("span.mention[data-mention-id]").map do |el|
        el['data-mention-id']
      end.filter { |id_or_username| id_or_username.to_i.to_s != id_or_username }
    end
  end

  def mentioned_user_ids
    # html text could use ids or usernames depending on the age of the content
    return [] if text_format == "md"
    Nokogiri::HTML(mentionable_text).search("span.mention[data-mention-id]").map do |el|
      el['data-mention-id']
    end.filter { |id_or_username| id_or_username.to_i.to_s == id_or_username }
  end

  def mentioned_users
    User.visible_by(author).where("username in (:usernames) or users.id in (:ids)", usernames: mentioned_usernames, ids: mentioned_user_ids)
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
