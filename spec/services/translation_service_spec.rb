require 'rails_helper'

describe 'TranslationService' do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:google_service) { double('google_translate_service') }

  before do
    ENV['TRANSLATE_CREDENTIALS'] = 'fake_credentials'
    allow(Google::Cloud::Translate).to receive(:translation_v2_service).and_return(google_service)
  end

  after do
    ENV.delete('TRANSLATE_CREDENTIALS')
  end

  describe '.create' do
    context 'with markdown formatted content' do
      let(:discussion) do
        create(:discussion,
               author: user,
               group: group,
               title: 'Test Title',
               description: "# Heading\n\n**Bold text** and *italic*\n\n- List item 1\n- List item 2",
               description_format: 'md')
      end

      it 'converts markdown to HTML and passes format: html to Google Translate' do
        expect(google_service).to receive(:translate) do |content, options|
          # Verify content is HTML (converted from markdown)
          expect(content).to include('<h1')
          expect(content).to include('<strong>')
          expect(content).to include('<em>')
          expect(content).to include('<li>')
          # Verify format option is set to html
          expect(options[:format]).to eq('html')
          expect(options[:to]).to eq('fr')
          # Return mock translated HTML
          '<h1>Titre</h1><p><strong>Texte gras</strong></p>'
        end.once

        expect(google_service).to receive(:translate) do |content, options|
          # Title field doesn't have format, so should translate as plain text
          expect(content).to eq('Test Title')
          expect(options[:format]).to be_nil
          expect(options[:to]).to eq('fr')
          'Titre du test'
        end.once

        translation = TranslationService.create(model: discussion, to: 'fr')

        expect(translation.fields['description']).to include('<h1>Titre</h1>')
        expect(translation.fields['title']).to eq('Titre du test')
      end
    end

    context 'with HTML formatted content' do
      let(:discussion) do
        create(:discussion,
               author: user,
               group: group,
               title: 'Test Title',
               description: '<h1>Heading</h1><p><strong>Bold text</strong></p>',
               description_format: 'html')
      end

      it 'passes HTML content with format: html to Google Translate' do
        expect(google_service).to receive(:translate) do |content, options|
          # Verify content is HTML
          expect(content).to include('<h1>')
          expect(content).to include('<strong>')
          # Verify format option is set to html
          expect(options[:format]).to eq('html')
          expect(options[:to]).to eq('de')
          '<h1>Überschrift</h1><p><strong>Fetter Text</strong></p>'
        end.once

        expect(google_service).to receive(:translate) do |content, options|
          expect(content).to eq('Test Title')
          expect(options[:format]).to be_nil
          'Test Titel'
        end.once

        translation = TranslationService.create(model: discussion, to: 'de')

        expect(translation.fields['description']).to include('<h1>Überschrift</h1>')
      end
    end

    context 'with plain text content' do
      let(:discussion) do
        create(:discussion,
               author: user,
               group: group,
               title: 'Simple Title',
               description: 'Simple description without formatting',
               description_format: 'md')
      end

      it 'still processes markdown format even for plain text' do
        expect(google_service).to receive(:translate) do |content, options|
          # Even plain text should be wrapped in HTML when format is md
          expect(options[:format]).to eq('html')
          expect(options[:to]).to eq('es')
          '<p>Descripción simple sin formato</p>'
        end.once

        expect(google_service).to receive(:translate).with('Simple Title', to: 'es').and_return('Título Simple')

        translation = TranslationService.create(model: discussion, to: 'es')

        expect(translation.persisted?).to be true
      end
    end

    context 'when model does not have format field' do
      let(:user_with_bio) { create(:user, name: 'John Doe') }

      it 'translates as plain text without format option' do
        # Assuming User model has translatable name but no name_format field
        allow(user_with_bio.class).to receive(:translatable_fields).and_return([:name])

        expect(google_service).to receive(:translate) do |content, options|
          expect(content).to eq('John Doe')
          expect(options[:format]).to be_nil
          expect(options[:to]).to eq('ja')
          'ジョン・ドウ'
        end

        translation = TranslationService.create(model: user_with_bio, to: 'ja')

        expect(translation.fields['name']).to eq('ジョン・ドウ')
      end
    end
  end

  describe '.available?' do
    it 'returns true when TRANSLATE_CREDENTIALS is set' do
      ENV['TRANSLATE_CREDENTIALS'] = 'fake_credentials'
      expect(TranslationService.available?).to be true
    end

    it 'returns false when TRANSLATE_CREDENTIALS is not set' do
      ENV.delete('TRANSLATE_CREDENTIALS')
      expect(TranslationService.available?).to be false
    end
  end
end
