require Rails.root.join('db/migrate/20260707000001_migrate_reactions_to_unicode')

class ShortcodeRichTextToUnicodeService
  SHORTCODE_PATTERN = /:([A-Za-z0-9_+\-]+):/.freeze
  SHORTCODE_SQL = ':[A-Za-z0-9_+\-]+:'

  Target = Struct.new(:model_class, :field, keyword_init: true)

  TARGETS = [
    Target.new(model_class: Comment, field: :body),
    Target.new(model_class: Discussion, field: :description),
    Target.new(model_class: Group, field: :description),
    Target.new(model_class: Poll, field: :details),
    Target.new(model_class: Outcome, field: :statement),
    Target.new(model_class: Stance, field: :reason),
    Target.new(model_class: PollTemplate, field: :details),
    Target.new(model_class: DiscussionTemplate, field: :description),
    Target.new(model_class: User, field: :short_bio)
  ].freeze

  TRANSLATED_FIELDS_BY_TYPE = {
    'Comment' => %w[body],
    'Discussion' => %w[description],
    'Group' => %w[description],
    'Poll' => %w[details],
    'Outcome' => %w[statement],
    'Stance' => %w[reason]
  }.freeze

  attr_reader :apply, :limit, :io

  def self.convert!(apply: true, limit: nil, io: $stdout)
    new(apply:, limit:, io:).convert
  end

  def initialize(apply:, limit: nil, io: $stdout)
    @apply = apply
    @limit = limit
    @io = io
  end

  def convert
    io.puts apply ? 'Applying rich-text shortcode conversion' : 'Dry run only. Set APPLY=1 to write changes'
    io.puts "LIMIT=#{limit}" if limit

    total_records = 0
    total_replacements = 0
    converted_counts_total = Hash.new(0)
    unknown_counts = Hash.new(0)

    TARGETS.each do |target|
      counts = convert_target(target, unknown_counts)
      total_records += counts[:records_changed]
      total_replacements += counts[:replacements]
      counts[:converted_counts].each { |code, count| converted_counts_total[code] += count }
    end

    counts = convert_translations(unknown_counts)
    total_records += counts[:records_changed]
    total_replacements += counts[:replacements]
    counts[:converted_counts].each { |code, count| converted_counts_total[code] += count }

    io.puts "\nTotal: #{total_records} records changed, #{total_replacements} replacements"

    if converted_counts_total.any?
      io.puts "\nConverted shortcodes:"
      print_counts(converted_counts_total, '  converted')
    end

    if unknown_counts.any?
      io.puts "\nUnknown shortcode-shaped tokens left unchanged:"
      print_counts(unknown_counts, '  unknown')
    end

    { records_changed: total_records, replacements: total_replacements, converted_counts: converted_counts_total, unknown_counts: }
  end

  private

  def convert_target(target, unknown_counts)
    records_seen = 0
    records_changed = 0
    replacements = 0
    converted_counts_total = Hash.new(0)

    relation_for(target).find_each do |record|
      records_seen += 1
      original = record.public_send(target.field)
      next if original.blank?

      converted, changed_count, converted_counts = convert_text(original, unknown_counts)
      next if converted == original

      records_changed += 1
      replacements += changed_count
      converted_counts.each { |code, count| converted_counts_total[code] += count }

      if apply
        record.update_columns(target.field => converted, updated_at: Time.current)
        refresh_search_document(record)
      end
    end

    io.puts "#{target.model_class.table_name}.#{target.field}: #{records_seen} scanned, #{records_changed} changed, #{replacements} replacements"

    { records_changed:, replacements:, converted_counts: converted_counts_total }
  end

  def convert_translations(unknown_counts)
    translation_scope = Translation.where(translatable_type: TRANSLATED_FIELDS_BY_TYPE.keys)
    translation_scope = translation_scope.limit(limit) if limit
    translations_seen = 0
    translations_changed = 0
    translation_replacements = 0
    converted_counts_total = Hash.new(0)

    translation_scope.find_each do |translation|
      fields = translation.fields || {}
      translated_fields = TRANSLATED_FIELDS_BY_TYPE.fetch(translation.translatable_type, [])
      next if translated_fields.none? { |field| fields[field].to_s.match?(SHORTCODE_PATTERN) }

      translations_seen += 1
      changed = false

      translated_fields.each do |field|
        original = fields[field]
        next if original.blank?

        converted, changed_count, converted_counts = convert_text(original, unknown_counts)
        next if converted == original

        fields[field] = converted
        changed = true
        translation_replacements += changed_count
        converted_counts.each { |code, count| converted_counts_total[code] += count }
      end

      next unless changed

      translations_changed += 1
      translation.update_columns(fields:, updated_at: Time.current) if apply
    end

    io.puts "translations.fields: #{translations_seen} scanned, #{translations_changed} changed, #{translation_replacements} replacements"

    { records_changed: translations_changed, replacements: translation_replacements, converted_counts: converted_counts_total }
  end

  def shortcode_unicode(code)
    MigrateReactionsToUnicode::SHORTCODE_TO_UNICODE[code]
  end

  def convert_text(text, unknown_counts)
    changed_count = 0
    converted_counts = Hash.new(0)

    converted = text.gsub(SHORTCODE_PATTERN) do |match|
      code = Regexp.last_match(1)
      unicode = shortcode_unicode(code)
      if unicode
        changed_count += 1
        converted_counts[code] += 1
        unicode
      else
        unknown_counts[code] += 1
        match
      end
    end

    [converted, changed_count, converted_counts]
  end

  def relation_for(target)
    table = target.model_class.quoted_table_name
    column = target.model_class.connection.quote_column_name(target.field)
    relation = target.model_class.where("#{table}.#{column} ~ ?", SHORTCODE_SQL)
    limit ? relation.limit(limit) : relation
  end

  def refresh_search_document(record)
    return unless record.respond_to?(:update_pg_search_document)

    record.update_pg_search_document
  end

  def print_counts(counts, prefix)
    counts.sort_by { |code, count| [-count, code] }.each do |code, count|
      io.puts "#{prefix}: :#{code}: x#{count}"
    end
  end
end
