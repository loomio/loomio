class TranscriptionService
  MODEL = "whisper-1".freeze

  def self.available?
    ENV['OPENAI_API_KEY'].present?
  end

  def self.transcribe(file)
    client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))

    Sentry.with_child_span(op: "gen_ai.chat", description: "#{MODEL} audio transcription") do |span|
      if span
        span.set_data("gen_ai.system", "openai")
        span.set_data("gen_ai.request.model", MODEL)
        span.set_data("gen_ai.operation.name", "audio.transcriptions.create")
      end

      response = client.audio.transcribe(
        parameters: {
          model: MODEL,
          file: file,
          response_format: :verbose_json,
        }
      )

      if span && response.is_a?(Hash)
        span.set_data("gen_ai.response.model", response["model"] || MODEL)
        span.set_data("gen_ai.audio.duration_seconds", response["duration"]) if response["duration"]
      end

      response
    end
  end
end