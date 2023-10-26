class TranscriptionService
  def self.available?
    ENV['OPENAI_API_KEY'].present?
  end

  def self.transcribe(file)
    client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
    client.audio.transcribe(
      parameters: {
        model: "whisper-1",
        file: file,
        response_format: :verbose_json,
      }
    )
  end
end