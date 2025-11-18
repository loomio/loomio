require 'rails_helper'

RSpec.describe TranslationService do
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
      end

      it 'uses the Rails I18n translation and does not call Google Translate' do
        google_service = double('GoogleTranslateService')
        allow(Google::Cloud::Translate).to receive(:translation_v2_service).and_return(google_service)
        expect(google_service).not_to receive(:translate)

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

      it 'falls back to Google Translate' do
        google_service = double('GoogleTranslateService')
        allow(Google::Cloud::Translate).to receive(:translation_v2_service).and_return(google_service)
        expect(google_service).to receive(:translate).with('Plan X', hash_including(to: 'fr', format: :text)).and_return('Plan X FR')

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
