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
        # Use flexible matching since fields may be translated in any order
        expect(google_service).to receive(:translate).twice do |content, options|
          expect(options[:to]).to eq('fr')

          if content == 'Test Title'
            # Title field doesn't have _format suffix, so should translate as plain text
            expect(options[:format]).to be_nil
            'Titre du test'
          else
            # Description field with markdown format
            expect(content).to include('<h1')
            expect(content).to include('<strong>')
            expect(content).to include('<em>')
            expect(content).to include('<li>')
            expect(options[:format]).to eq('html')
            '<h1>Titre</h1><p><strong>Texte gras</strong></p>'
          end
        end

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
        expect(google_service).to receive(:translate).twice do |content, options|
          expect(options[:to]).to eq('de')

          if content == 'Test Title'
            # Title field doesn't have _format suffix
            expect(options[:format]).to be_nil
            'Test Titel'
          else
            # Description field with HTML format - check for HTML elements (may have attributes like id)
            expect(content).to match(/<h1[^>]*>/)
            expect(content).to include('<strong>')
            expect(options[:format]).to eq('html')
            '<h1>Überschrift</h1><p><strong>Fetter Text</strong></p>'
          end
        end

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
        expect(google_service).to receive(:translate).twice do |content, options|
          expect(options[:to]).to eq('es')

          if content == 'Simple Title'
            # Title field doesn't have _format suffix
            expect(options[:format]).to be_nil
            'Título Simple'
          else
            # Even plain text should be wrapped in HTML when format is md
            expect(options[:format]).to eq('html')
            '<p>Descripción simple sin formato</p>'
          end
        end

        translation = TranslationService.create(model: discussion, to: 'es')

        expect(translation.persisted?).to be true
      end
    end

    context 'when model does not have format field' do
      let(:tag) { create(:tag, name: 'Important', group: group) }

      it 'translates as plain text without format option' do
        expect(google_service).to receive(:translate) do |content, options|
          expect(content).to eq('Important')
          expect(options[:format]).to be_nil
          expect(options[:to]).to eq('ja')
          '重要'
        end

        translation = TranslationService.create(model: tag, to: 'ja')

        expect(translation.fields['name']).to eq('重要')
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
