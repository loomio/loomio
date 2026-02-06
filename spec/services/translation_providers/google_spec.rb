require 'rails_helper'

RSpec.describe TranslationProviders::Google do
  describe '.available?' do
    it 'returns true when TRANSLATE_CREDENTIALS is set' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('TRANSLATE_CREDENTIALS').and_return('credentials')
      expect(TranslationProviders::Google.available?).to eq true
    end

    it 'returns false when TRANSLATE_CREDENTIALS is not set' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('TRANSLATE_CREDENTIALS').and_return(nil)
      expect(TranslationProviders::Google.available?).to eq false
    end
  end

  describe '#translate' do
    it 'calls Google Cloud Translate service' do
      google_service = double('GoogleTranslateService')
      allow(Google::Cloud::Translate).to receive(:translation_v2_service).and_return(google_service)
      expect(google_service).to receive(:translate).with('Hello', to: 'fr', format: :text).and_return('Bonjour')

      provider = TranslationProviders::Google.new
      result = provider.translate('Hello', to: 'fr', format: :text)

      expect(result).to eq 'Bonjour'
    end

    it 'supports HTML format' do
      google_service = double('GoogleTranslateService')
      allow(Google::Cloud::Translate).to receive(:translation_v2_service).and_return(google_service)
      expect(google_service).to receive(:translate).with('<p>Hello</p>', to: 'fr', format: :html).and_return('<p>Bonjour</p>')

      provider = TranslationProviders::Google.new
      result = provider.translate('<p>Hello</p>', to: 'fr', format: :html)

      expect(result).to eq '<p>Bonjour</p>'
    end

    it 'raises QuotaExceededError when quota limit hit' do
      google_service = double('GoogleTranslateService')
      quota_error = Google::Cloud::Error.new('Quota exceeded')
      allow(Google::Cloud::Translate).to receive(:translation_v2_service).and_return(google_service)
      allow(google_service).to receive(:translate).and_raise(quota_error)

      provider = TranslationProviders::Google.new

      expect {
        provider.translate('Hello', to: 'fr', format: :text)
      }.to raise_error(TranslationService::QuotaExceededError)
    end
  end

  describe '#normalize_locale' do
    it 'converts underscore to hyphen and returns locale if supported' do
      provider = TranslationProviders::Google.new
      expect(provider.normalize_locale('zh_CN')).to eq 'zh-cn'
    end

    it 'returns locale if it is in SUPPORTED_LOCALES' do
      provider = TranslationProviders::Google.new
      expect(provider.normalize_locale('fr')).to eq 'fr'
      expect(provider.normalize_locale('zh-CN')).to eq 'zh-cn'
    end

    it 'returns base language for unsupported variants' do
      provider = TranslationProviders::Google.new
      expect(provider.normalize_locale('fr-CA')).to eq 'fr'
    end
  end
end
