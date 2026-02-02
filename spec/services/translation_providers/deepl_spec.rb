require 'rails_helper'

RSpec.describe TranslationProviders::Deepl do
  describe '.available?' do
    it 'returns true when DEEPL_API_KEY is set' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('DEEPL_API_KEY').and_return('test-key')
      expect(TranslationProviders::Deepl.available?).to eq true
    end

    it 'returns false when DEEPL_API_KEY is not set' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('DEEPL_API_KEY').and_return(nil)
      expect(TranslationProviders::Deepl.available?).to eq false
    end
  end

  describe '#translate' do
    let(:provider) { TranslationProviders::Deepl.new }
    let(:api_response) { { 'translations' => [{ 'text' => 'Bonjour', 'detected_source_language' => 'EN' }] }.to_json }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('DEEPL_API_KEY').and_return('test-key')
    end

    context 'with pro API key' do
      it 'makes a POST request to DeepL Pro API' do
        stub_request(:post, "https://api.deepl.com/v2/translate")
          .with(
            body: "text=Hello&target_lang=FR",
            headers: {
              'Authorization' => 'DeepL-Auth-Key test-key',
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          )
          .to_return(status: 200, body: api_response)

        result = provider.translate('Hello', to: 'fr', format: :text)

        expect(result).to eq 'Bonjour'
      end
    end

    context 'with free API key' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('DEEPL_API_KEY').and_return('test-key:fx')
      end

      it 'makes a POST request to DeepL Free API' do
        stub_request(:post, "https://api-free.deepl.com/v2/translate")
          .with(
            body: "text=Hello&target_lang=FR",
            headers: {
              'Authorization' => 'DeepL-Auth-Key test-key:fx',
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          )
          .to_return(status: 200, body: api_response)

        result = provider.translate('Hello', to: 'fr', format: :text)

        expect(result).to eq 'Bonjour'
      end
    end

    it 'supports HTML format' do
      stub_request(:post, "https://api.deepl.com/v2/translate")
        .with(body: "text=%3Cp%3EHello%3C%2Fp%3E&target_lang=FR&tag_handling=html")
        .to_return(status: 200, body: { 'translations' => [{ 'text' => '<p>Bonjour</p>' }] }.to_json)

      result = provider.translate('<p>Hello</p>', to: 'fr', format: :html)

      expect(result).to eq '<p>Bonjour</p>'
    end
  end

  describe '#normalize_locale' do
    let(:provider) { TranslationProviders::Deepl.new }

    it 'converts underscore to hyphen and returns base language' do
      expect(provider.normalize_locale('fr_CA')).to eq 'fr'
    end

    it 'returns base language if supported' do
      expect(provider.normalize_locale('fr')).to eq 'fr'
      expect(provider.normalize_locale('de')).to eq 'de'
    end

    it 'returns base language for locale variants' do
      expect(provider.normalize_locale('en-US')).to eq 'en'
      expect(provider.normalize_locale('pt-BR')).to eq 'pt'
    end
  end
end
