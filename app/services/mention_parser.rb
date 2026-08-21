class MentionParser
  # Usernames and group handles share these characters in Markdown mentions.
  # Hyphens must separate non-empty segments so sentence punctuation such as
  # "Thanks @sam-" still mentions sam rather than looking for "sam-".
  HANDLE_PATTERN_SOURCE = '[a-z0-9_]+(?:-[a-z0-9_]+)*'.freeze
  USERNAME_PATTERN = /\A#{HANDLE_PATTERN_SOURCE}\z/
  MARKDOWN_PATTERN = /(?<![[:alnum:]_])@(#{HANDLE_PATTERN_SOURCE})/i

  def self.usernames(text)
    String(text).scan(MARKDOWN_PATTERN).flatten.map(&:downcase).uniq
  end
end
