# https://www.modern-rails.com/posts/activestorage-analyzers-and-the-openai-transcription-api/
class TranscriptionAnalyzer < ActiveStorage::Analyzer::AudioAnalyzer
  def metadata
    super.merge(text: @text, language: @language).compact
  end

  private

  def probe_from(file)
    super.tap do
      attachment = blob.attachments.first
      next unless attachment

      record = attachment.record
      next unless attachment.name.in?(%w[files image_files]) && record.class.respond_to?(:rich_text_fields)

      field = record.class.rich_text_fields.first
      response = TranscriptionService.transcribe(file)
      @text = response["text"]
      @language = response["language"]
      record[field] = "#{record[field]}<p>#{@text}</p>"
      record.save!
      if record.respond_to?(:group_id) && record.respond_to?(:author_id)
        MessageChannelService.publish_models(Array(record), group_id: record.group_id, user_id: record.author_id)
      end
    end
  end
end
