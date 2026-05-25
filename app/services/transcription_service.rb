class TranscriptionService
  def self.available?
    ENV['OPENAI_API_KEY'].present?
  end

  TRIAL_DAILY_LIMIT = 3
  PAID_DAILY_LIMIT = 30

  def self.transcribe(file, user: nil)
    return unless within_daily_limit?(user)

    client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
    client.audio.transcribe(
      parameters: {
        model: "whisper-1",
        file: file,
        response_format: :verbose_json,
      }
    )
  rescue Faraday::TooManyRequestsError => e
    Rails.logger.warn("OpenAI transcription skipped after rate limit: #{e.message}")
    nil
  end

  def self.within_daily_limit?(user)
    return true unless user

    limit = daily_limit_for(user)
    allowed = ThrottleService.can?(key: 'Transcription', id: user.id, max: limit, per: 'day')
    Rails.logger.info("OpenAI transcription skipped after daily limit reached for user #{user.id}") unless allowed
    allowed
  end

  def self.daily_limit_for(user)
    user.is_paying? ? PAID_DAILY_LIMIT : TRIAL_DAILY_LIMIT
  end
end
