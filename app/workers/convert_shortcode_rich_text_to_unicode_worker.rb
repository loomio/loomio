class ConvertShortcodeRichTextToUnicodeWorker < ApplicationJob
  queue_as :low

  def perform
    ShortcodeRichTextToUnicodeService.convert!(apply: true)
  end
end
