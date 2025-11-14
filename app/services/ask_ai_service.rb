# frozen_string_literal: true

# AskAiService
#
# Given a discussion id and a prompt, this service assembles the discussion
# context (title, description, author, and all comments with their authors)
# and queries OpenAI for a response.
#
# Configuration (ENV):
# - OPENAI_API_KEY        : required
# - OPENAI_CHAT_MODEL     : default "gpt-4o-mini"
# - OPENAI_TEMPERATURE    : default "0.2"
# - ASK_AI_MAX_CONTEXT_CHARS : default "200000" (soft limit for context size)
#
# Usage:
#   AskAiService.ask(discussion_id: 123, prompt: "Summarise ...")
#
# Returns a Hash:
#   {
#     answer: "string",
#     model: "model-name",
#     usage: {...},      # if available from OpenAI
#     id: "chatcmpl-..." # if available from OpenAI
#   }
#
class AskAiService
  DEFAULT_PROMPT = 'Summarise the discussion, find points of agreement and disagreement and suggest a next step.'.freeze
  DEFAULT_MODEL = 'gpt-4o-mini'
  DEFAULT_TEMPERATURE = 0.2
  DEFAULT_MAX_CONTEXT_CHARS = 200_000

  class MissingApiKeyError < StandardError; end

  class << self
    def ask(discussion_id:, prompt: DEFAULT_PROMPT, actor: nil)
      ensure_api_key!

      discussion = Discussion
        .includes(comments: :user, author: [])
        .find(discussion_id)

      context_text = build_context(discussion)
      full_prompt = [prompt.to_s.strip, '', 'Context:', context_text].join("\n")

      client = openai_client
      model = ENV.fetch('OPENAI_CHAT_MODEL', DEFAULT_MODEL)
      temperature = ENV.fetch('OPENAI_TEMPERATURE', DEFAULT_TEMPERATURE.to_s).to_f

      response = client.chat(
        parameters: {
          model: model,
          temperature: temperature,
          messages: [
            {
              role: 'system',
              content: 'You are a helpful assistant that analyzes Loomio discussions to help groups collaborate. Be concise yet comprehensive. Just respond to the user. Dont add a summary when not asked to do so.'
            },
            {
              role: 'user',
              content: full_prompt
            }
          ]
        }
      )

      answer = response.dig('choices', 0, 'message', 'content').to_s

      {
        answer: answer,
        model: model,
        usage: response['usage'],
        id: response['id']
      }
    rescue ActiveRecord::RecordNotFound
      raise
    rescue MissingApiKeyError
      raise
    rescue => e
      Rails.logger.error("AskAiService error: #{e.class} #{e.message}")
      raise
    end

    # Extract candidate poll options (name and meaning) from a discussion using AI.
    #
    # Returns a Hash:
    #   { options: [ {name: "short title", meaning: "longer plain text"}, ... ] }
    #
    # Options are deduplicated (case-insensitive), trimmed, and limited to `max`.
    def extract_poll_options(discussion_id:, max: 30, actor: nil)
      ensure_api_key!

      discussion = Discussion
        .includes(comments: :user, author: [])
        .find(discussion_id)

      context_text = build_context(discussion)

      prompt = <<~PROMPT
        You are helping prepare candidate options for a Loomio poll based on a discussion.

        Task:
        - Extract up to #{max} distinct option ideas suggested or implied by the participants.
        - Each option has:
          - "name": a concise neutral title, at most 60 characters, no numbering/bullets/quotes.
          - "meaning": an optional plain-text explanation, at most 400 characters.

        Guidelines:
        - Avoid duplicates and near-duplicates; keep options mutually exclusive where possible.
        - Keep language neutral and easy to understand by a general audience.
        - Do not include markdown or links. Plain text only.

        Output:
        - Respond with strict JSON only in exactly this format (no extra commentary):
          {"options":[{"name":"...","meaning":"..."}, ...]}

        Discussion Context:
        #{context_text}
      PROMPT

      client = openai_client
      model = ENV.fetch('OPENAI_CHAT_MODEL', DEFAULT_MODEL)
      temperature = ENV.fetch('OPENAI_TEMPERATURE', DEFAULT_TEMPERATURE.to_s).to_f

      response = client.chat(
        parameters: {
          model: model,
          temperature: temperature,
          messages: [
            {
              role: 'system',
              content: 'You extract structured poll option candidates from discussions. Respond with valid JSON only.'
            },
            {
              role: 'user',
              content: prompt
            }
          ]
        }
      )

      raw = response.dig('choices', 0, 'message', 'content').to_s

      # Attempt to parse JSON strictly; if malformed, try to extract the first JSON object, else fallback
      data = begin
        JSON.parse(raw)
      rescue JSON::ParserError
        if raw.include?('{') && raw.include?('}')
          begin
            json_str = raw[raw.index('{')..raw.rindex('}')]
            JSON.parse(json_str)
          rescue JSON::ParserError
            {}
          end
        else
          {}
        end
      end

      options = (data['options'] || data[:options] || [])

      # Fallback: extract simple lines as names if no options present
      if options.empty?
        lines = raw.split("\n").map(&:strip).reject(&:empty?)
        names = lines.map { |l| l.sub(/^\d+[\.\)]\s*/, '').sub(/^[-*]\s*/, '') }
        options = names.map { |n| { 'name' => n, 'meaning' => nil } }
      end

      normalized = []
      seen = {}

      options.each do |opt|
        if opt.is_a?(String)
          name = opt
          meaning = nil
        else
          name = opt['name'] || opt[:name]
          meaning = opt['meaning'] || opt[:meaning]
        end

        next unless name
        name = name.to_s.strip
        next if name.empty?

        # Clean and constrain lengths
        name = name.gsub(/\A["“”']+|["“”']+\z/, '')
        name = name[0, 60]

        meaning = meaning.to_s.strip
        meaning = nil if meaning.empty?
        meaning = meaning[0, 400] if meaning

        key = name.downcase
        next if seen[key]

        normalized << { name: name, meaning: meaning }
        seen[key] = true
        break if normalized.size >= max
      end

      { options: normalized }
    end

    # Build a plain-text context block representing the discussion and its comments.
    #
    # Includes:
    # - Discussion title, author, description (stripped of HTML if necessary)
    # - All non-discarded comments in chronological order with author and timestamp
    #
    # Will softly truncate context if it exceeds ASK_AI_MAX_CONTEXT_CHARS.
    #
    def build_context(discussion)
      header = build_header_block(discussion)
      comments_block, omitted_count = build_comments_block(discussion)

      parts = [header, comments_block]
      text = parts.compact.join("\n\n")

      max_chars = ENV.fetch('ASK_AI_MAX_CONTEXT_CHARS', DEFAULT_MAX_CONTEXT_CHARS.to_s).to_i
      if text.length > max_chars
        # As a last resort, trim comments block to fit within the budget.
        header_len = header.length + 2
        remaining = [max_chars - header_len, 0].max
        text = [header, comments_block.truncate(remaining, omission: "\n\n...[truncated to fit model context]")].join("\n\n")
      end

      if omitted_count.positive?
        [text, "\n\nNotes: #{omitted_count} older comments were omitted due to context size."].join
      else
        text
      end
    end

    def scaffold_poll(discussion_id:, prompt: nil, max: 30, actor: nil)
      ensure_api_key!

      discussion = Discussion
        .includes(comments: :user, author: [])
        .find(discussion_id)

      context_text = build_context(discussion)

      default_prompt = <<~PROMPT
        You are helping prepare a Loomio poll scaffold based on a discussion.

        Task:
        - Propose a concise poll title.
        - Draft a short plain-text description (details) that introduces the poll context (<= 600 characters).
        - Extract up to #{max} distinct option ideas suggested or implied by the discussion.
          Each option must include:
            - "name": a concise neutral title, <= 60 chars, no numbering/bullets/quotes.
            - "meaning": an optional plain-text explanation, <= 400 chars.

        Guidelines:
        - Avoid duplicates and near-duplicates; keep options mutually exclusive where possible.
        - Keep language neutral, suitable for a general audience.
        - Do not include markdown or links. Plain text only.

        Output:
        - Respond with strict JSON only, exactly this shape (no commentary):
          {"title":"...","details":"...","options":[{"name":"...","meaning":"..."}, ...]}

        Discussion Context:
        #{context_text}
      PROMPT

      prompt ||= default_prompt

      client = openai_client
      model = ENV.fetch('OPENAI_CHAT_MODEL', DEFAULT_MODEL)
      temperature = ENV.fetch('OPENAI_TEMPERATURE', DEFAULT_TEMPERATURE.to_s).to_f

      response = client.chat(
        parameters: {
          model: model,
          temperature: temperature,
          messages: [
            {
              role: 'system',
              content: 'You produce structured poll scaffolds from discussions. Respond with valid JSON only.'
            },
            {
              role: 'user',
              content: prompt
            }
          ]
        }
      )

      raw = response.dig('choices', 0, 'message', 'content').to_s

      data = begin
        JSON.parse(raw)
      rescue JSON::ParserError
        if raw.include?('{') && raw.include?('}')
          begin
            json_str = raw[raw.index('{')..raw.rindex('}')]
            JSON.parse(json_str)
          rescue JSON::ParserError
            {}
          end
        else
          {}
        end
      end

      title   = (data['title'] || data[:title]).to_s.strip
      details = (data['details'] || data[:details]).to_s.strip
      options = (data['options'] || data[:options] || [])

      # Normalize options to [{name, meaning}] with length constraints and dedupe
      normalized = []
      seen = {}
      options.each do |opt|
        name = opt.is_a?(String) ? opt : (opt['name'] || opt[:name])
        meaning = opt.is_a?(String) ? nil : (opt['meaning'] || opt[:meaning])

        next unless name
        name = name.to_s.strip
        next if name.empty?

        name = name.gsub(/\A["“”']+|["“”']+\z/, '')
        name = name[0, 60]

        meaning = meaning.to_s.strip
        meaning = nil if meaning.empty?
        meaning = meaning[0, 400] if meaning

        key = name.downcase
        next if seen[key]
        seen[key] = true

        normalized << { name: name, meaning: meaning }
        break if normalized.size >= max
      end

      title = (title.presence || discussion.title.to_s[0, 150]).to_s
      details = details.presence

      { title: title, details: details, options: normalized }
    end

    private

    def ensure_api_key!
      raise MissingApiKeyError, 'OPENAI_API_KEY is not set' if ENV['OPENAI_API_KEY'].to_s.strip.empty?
    end

    def openai_client
      require 'openai'
      OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    end

    def build_header_block(discussion)
      author_name = discussion.author&.name.to_s.presence || 'Unknown'
      title = discussion.title.to_s
      description = plain_text(discussion.description.to_s, discussion.description_format)

      [
        "Discussion Title: #{title}",
        "Author: #{author_name}",
        "Description:\n#{description}".strip
      ].join("\n\n")
    end

    # Returns [comments_text, omitted_count]
    def build_comments_block(discussion)
      comments = discussion.comments
                           .where(discarded_at: nil)
                           .includes(:user, :parent)
                           .order(:created_at)

      lines = []
      lines << "Comments (#{comments.size}):"

      base = lines.join("\n")
      max_chars = ENV.fetch('ASK_AI_MAX_CONTEXT_CHARS', DEFAULT_MAX_CONTEXT_CHARS.to_s).to_i

      omitted = 0
      # Build all lines first, then we will optionally omit from the head if too long.
      comment_lines = comments.map.with_index(1) do |c, idx|
        author = c.author&.name.to_s.presence || 'Unknown'
        ts = c.created_at&.utc&.iso8601

        body = plain_text(c.body.to_s, c.body_format)
        reply_prefix = c.parent_type == 'Comment' ? "Reply to #{c.parent_author&.name}: " : ''
        "- [#{idx}] #{author} at #{ts}:\n  #{reply_prefix}#{body}"
      end

      # Soft pack within max context by omitting earliest lines if necessary.
      packed = (lines + comment_lines).join("\n\n")
      if packed.length > max_chars
        # keep the end of comments (most recent) and include as many as fit
        header_len = base.length + 2
        remaining = [max_chars - header_len, 0].max

        kept = []
        running = 0
        comment_lines.reverse_each do |line|
          len = line.length + 2
          break if running + len > remaining
          kept << line
          running += len
        end

        omitted = comment_lines.size - kept.size
        kept.reverse!
        [(lines + kept).join("\n\n"), omitted]
      else
        [packed, omitted]
      end
    end

    # Convert HTML or plain text to plain text
    def plain_text(str, format)
      text = str.to_s
      if format.to_s == 'html'
        # Use Rails sanitizer to strip tags
        @full_sanitizer ||= ActionView::Base.full_sanitizer
        text = @full_sanitizer.sanitize(text)
      end
      text.strip
    end
  end
end

# ActiveSupport String#truncate fallback (in case we ever call outside Rails)
unless ''.respond_to?(:truncate)
  class String
    def truncate(max, omission: '...')
      return self if length <= max
      return omission if max <= omission.length
      self[0, max - omission.length] + omission
    end
  end
end
