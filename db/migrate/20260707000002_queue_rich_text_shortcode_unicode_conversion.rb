class QueueRichTextShortcodeUnicodeConversion < ActiveRecord::Migration[8.0]
  def up
    ConvertShortcodeRichTextToUnicodeWorker.perform_later
  end

  def down
    # No-op. The conversion is intentionally one-way and idempotent.
  end
end
