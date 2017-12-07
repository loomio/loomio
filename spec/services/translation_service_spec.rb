require 'rails_helper'

describe TranslationService do
  let(:fr_discussion) { create :discussion, author: fr_user }
  let(:fr_FR_discussion) { create :discussion, author: fr_user }
  let(:wark_discussion) { create :discussion, author: wark_user }
  let(:fr_user) { create :user, selected_locale: :fr }
  let(:fr_FR_user) { create :user, selected_locale: :fr_FR }
  let(:wark_user) { create :user, selected_locale: :wark }
  before do
    TranslationService.class_variable_set("@@supported_languages", nil)
    TranslationService.stub(:translator).and_return(StubTranslator.new)
  end

  it 'translates a valid language code' do
    expect { TranslationService.create(model: fr_discussion, to: :en) }.to change { fr_discussion.translations.count }.by(1)
  end

  it 'translates to via fallback' do
    expect { TranslationService.create(model: fr_discussion, to: :en_US) }.to change { fr_discussion.translations.count }.by(1)
  end

  it 'translates from via fallback' do
    expect { TranslationService.create(model: fr_FR_discussion, to: :en) }.to change { fr_FR_discussion.translations.count }.by(1)
  end

  it 'does not translate an invalid from language code' do
    expect { TranslationService.create(model: wark_discussion, to: :en) }.to_not change { wark_discussion.translations.count }
  end

  it 'does not translate an invalid to language code' do
    expect { TranslationService.create(model: fr_discussion, to: :wark) }.to_not change { fr_discussion.translations.count }
  end
end

class StubTranslator
  def supported_language_codes
    ['en', 'fr']
  end

  def translate(text = nil, from: nil, to: nil)
    "Sacre Bleu!"
  end
end
