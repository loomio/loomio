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
    mentioned = extract_mentions.uniq

    if text_format == "md"
      mentioned.map! { |audience| Audience.back_translate(audience) }
    end

    mentioned.filter { |audience| Audience.all.include? audience }
  end

  # audience mentioned in the text, but not yet sent notifications
  def newly_mentioned_audiences
    mentioned_audiences - already_mentioned_audiences
  end

  # audience mentioned on a previous edit of this model
  def already_mentioned_audiences
    self.events.reduce([]) { |result, event| result |= (event.custom_fields['audiences'] || []) }
  end

  private

  def text_format
    self.send("#{self.class.mentionable_fields.first}_format")
  end

  def mentionable_text
    self.class.mentionable_fields.map { |field| self.send(field) }.join('|')
  end

  def extract_mentions
    if text_format == "md"
      extract_mentioned_screen_names(mentionable_text)
    else
      Nokogiri::HTML::fragment(mentionable_text).search("span[data-mention-id]").map do |el|
        el['data-mention-id']
      end
    end
  end
end
