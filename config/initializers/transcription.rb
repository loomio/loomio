if ENV['OPENAI_API_KEY']
  require_relative '../../lib/analyzers/transcription_analyzer'
  Rails.application.config.active_storage.analyzers.delete ActiveStorage::Analyzer::AudioAnalyzer
  Rails.application.config.active_storage.analyzers.push(TranscriptionAnalyzer)
end