require 'rails_helper'

RSpec.describe TranslationProviders::ProviderManager do
  describe '#next_available_provider' do
    it 'returns first non-exhausted provider' do
      allow(TranslationProviders::Azure).to receive(:available?).and_return(true)
      allow(TranslationProviders::Google).to receive(:available?).and_return(true)

      manager = TranslationProviders::ProviderManager.new
      expect(manager.next_available_provider).to be_a(TranslationProviders::Azure)
    end

    it 'skips exhausted providers' do
      allow(TranslationProviders::Azure).to receive(:available?).and_return(true)
      allow(TranslationProviders::Google).to receive(:available?).and_return(true)
      allow(Date).to receive(:current).and_return(Date.parse('2026-02-01'))

      manager = TranslationProviders::ProviderManager.new
      azure = manager.next_available_provider
      manager.mark_provider_exhausted(azure)

      expect(manager.next_available_provider).to be_a(TranslationProviders::Google)
    end

    it 'resets exhausted providers on new day' do
      allow(TranslationProviders::Azure).to receive(:available?).and_return(true)
      allow(TranslationProviders::Google).to receive(:available?).and_return(false)

      manager = TranslationProviders::ProviderManager.new
      azure = manager.next_available_provider

      allow(Date).to receive(:current).and_return(Date.parse('2026-02-01'))
      manager.mark_provider_exhausted(azure)
      expect(manager.next_available_provider).to be_nil

      allow(Date).to receive(:current).and_return(Date.parse('2026-02-02'))
      expect(manager.next_available_provider).to be_a(TranslationProviders::Azure)
    end

    it 'returns nil when all providers exhausted' do
      allow(TranslationProviders::Azure).to receive(:available?).and_return(true)
      allow(TranslationProviders::Google).to receive(:available?).and_return(true)
      allow(Date).to receive(:current).and_return(Date.parse('2026-02-01'))

      manager = TranslationProviders::ProviderManager.new
      azure = manager.next_available_provider
      manager.mark_provider_exhausted(azure)

      google = manager.next_available_provider
      manager.mark_provider_exhausted(google)

      expect(manager.next_available_provider).to be_nil
    end
  end
end
