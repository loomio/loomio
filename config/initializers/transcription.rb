if ENV['OPENAI_API_KEY']
  require_relative '../../lib/transcription_analyzer'
  Rails.application.config.active_storage.analyzers.delete ActiveStorage::Analyzer::AudioAnalyzer
  if defined?(ActiveStorage::HotCell::Client::Analyzers::Audio::FFprobe)
    Rails.application.config.active_storage.analyzers.delete ActiveStorage::HotCell::Client::Analyzers::Audio::FFprobe
  end
  Rails.application.config.active_storage.analyzers.push(TranscriptionAnalyzer)
end
