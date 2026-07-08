#!/usr/bin/env ruby
# frozen_string_literal: true

# Convert legacy :shortcode: emoji tokens in rich-text fields to unicode.
#
# Dry run:
#   RAILS_ENV=production bundle exec rails runner db/scripts/convert_shortcode_rich_text_to_unicode.rb
#
# Apply changes:
#   APPLY=1 RAILS_ENV=production bundle exec rails runner db/scripts/convert_shortcode_rich_text_to_unicode.rb
#
# Only shortcodes from the legacy emoji table are converted. Unknown
# shortcode-shaped text is reported and left untouched.

ShortcodeRichTextToUnicodeService.convert!(
  apply: ENV.key?('APPLY'),
  limit: ENV['LIMIT']&.to_i
)
