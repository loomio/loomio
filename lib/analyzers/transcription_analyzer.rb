# https://www.modern-rails.com/posts/activestorage-analyzers-and-the-openai-transcription-api/
class TranscriptionAnalyzer < ActiveStorage::Analyzer::AudioAnalyzer
  def metadata
    super.merge(text: @text, language: @language).compact
  end

  private

  def probe_from(file)
    super.tap do
      response = TranscriptionService.transcribe(file)
      @text = response["text"]
      @language = response["language"]
      record = blob.attachments.first.record
      record.body += "<p>Audio Transcript: #{@text}</p>"
      record.save!
      MessageChannelService.publish_models(Array(record), group_id: record.group_id, user_id: record.author_id)
    end
  end
end