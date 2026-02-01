require 'rails_helper'

RSpec.describe TranslationService do
  describe '.provider' do
    before do
      TranslationService.instance_variable_set(:@provider, nil)
    end

    it 'prefers Azure when available' do
      allow(TranslationProviders::Azure).to receive(:available?).and_return(true)
      allow(TranslationProviders::Google).to receive(:available?).and_return(true)

      provider = TranslationService.provider

      expect(provider).to be_a(TranslationProviders::Azure)
    end

    it 'uses Google when Azure is not available' do
      allow(TranslationProviders::Azure).to receive(:available?).and_return(false)
      allow(TranslationProviders::Google).to receive(:available?).and_return(true)

      provider = TranslationService.provider

      expect(provider).to be_a(TranslationProviders::Google)
    end

    it 'returns nil when no provider is available' do
      allow(TranslationProviders::Azure).to receive(:available?).and_return(false)
      allow(TranslationProviders::Google).to receive(:available?).and_return(false)

      provider = TranslationService.provider

      expect(provider).to be_nil
    end
  end


  describe '.create' do
    let(:poll) { create(:poll, poll_option_names: []) }
    let(:poll_option) { create(:poll_option, poll: poll, name: name) }

    before do
      @old_backend = I18n.backend
      @old_locale = I18n.locale
      @old_enforce = I18n.enforce_available_locales

      # Ensure English source locale for the model
      I18n.locale = :en
      poll.update!(content_locale: 'en') if poll.respond_to?(:content_locale=)

      # Isolate and seed I18n translations for this spec
      I18n.backend = I18n::Backend::Simple.new
      I18n.enforce_available_locales = false

      # Reset provider cache between tests
      TranslationService.instance_variable_set(:@provider, nil)
    end

    after do
      I18n.backend = @old_backend
      I18n.locale = @old_locale
      I18n.enforce_available_locales = @old_enforce
    end

    context 'when field is an I18n-known label (wildcard match)' do
      let(:name) { 'Agree' }

      before do
        # Provide translations under a wildcard-able namespace:
        # KNOWN_I18N_LABEL_KEYS includes "poll_proposal_options.*"
        I18n.backend.store_translations(:en, poll_proposal_options: { agree: 'Agree' })
        I18n.backend.store_translations(:fr, poll_proposal_options: { agree: "D’accord" })

        allow(TranslationProviders::Google).to receive(:available?).and_return(true)
      end

      it 'uses the Rails I18n translation and does not call provider' do
        provider = double('TranslationProvider')
        allow(provider).to receive(:normalize_locale).and_return('fr')
        allow(TranslationService).to receive(:provider).and_return(provider)
        expect(provider).not_to receive(:translate)

        translation = TranslationService.create(model: poll_option, to: 'fr')

        expect(translation).to be_persisted
        expect(translation.language).to eq 'fr'
        expect(translation.fields['name']).to eq "D’accord"
        expect(translation.fields['meaning']).to be_nil
        expect(translation.fields['prompt']).to be_nil
      end
    end

    context 'when field is not an I18n-known label' do
      let(:name) { 'Plan X' }

      before do
        allow(TranslationProviders::Google).to receive(:available?).and_return(true)
      end

      it 'falls back to translation provider' do
        provider = double('TranslationProvider')
        allow(provider).to receive(:normalize_locale).and_return('fr')
        allow(TranslationService).to receive(:provider).and_return(provider)
        expect(provider).to receive(:translate).with('Plan X', hash_including(to: 'fr', format: :text)).and_return('Plan X FR')

        translation = TranslationService.create(model: poll_option, to: 'fr')

        expect(translation).to be_persisted
        expect(translation.language).to eq 'fr'
        expect(translation.fields['name']).to eq 'Plan X FR'
        expect(translation.fields['meaning']).to be_nil
        expect(translation.fields['prompt']).to be_nil
      end
    end
  end
end
