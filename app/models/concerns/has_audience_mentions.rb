module HasAudienceMentions
  extend ActiveSupport::Concern
  include Twitter::Extractor
  include HasEvents

  module ClassMethods
    def is_mentionable(on: [])
      define_singleton_method :mentionable_fields, -> { Array on }
    end
  end

  def mentioned_audiences
    audiences = MentionableCollection.pluck(:name)

    if text_format == "md"
      extract_mentioned_screen_names(mentionable_text).uniq - [self.author&.username]
    else
      Nokogiri::HTML::fragment(mentionable_text).search("span[data-mention-id]").map do |el|
        el['data-mention-id']
      end.filter { |audience| %w[group discussion].include? audience }
    end
  end

  # audience mentioned in the text, but not yet sent notifications
  def newly_mentioned_audiences
    mentioned_audiences - already_mentioned_audiences
  end

  # audience mentioned on a previous edit of this model
  def already_mentioned_audiences
    self.notifications.user_mentions.pluck(:audience)
  end

  # TODO: use this or similar method for translated audience
  def translated_audiences
    audiences = {
      I18n.t(:"user.mentionable_collection.#{'group'}", default: 'group' ) => 'group',
      I18n.t(:"user.mentionable_collection.#{'thread'}", default: 'discussion' ) => 'discussion_group'
    }
  end

  private

  def text_format
    self.send("#{self.class.mentionable_fields.first}_format")
  end

  def mentionable_text
    self.class.mentionable_fields.map { |field| self.send(field) }.join('|')
  end
end
