require 'rails_helper'

describe ClientTranslationService do
  it 'returns translations given a lang' do
    expect(ClientTranslationService.new(:fr).as_json['common']['action']['close']).to eq 'Fermer'
  end

  it 'falls back to the default locale if translation does not exist' do
    expect(ClientTranslationService.new(:vi).as_json['common']['action']['close']).to eq 'Close'
  end

  it 'falls back to the default locale if no locale is given' do
    expect(ClientTranslationService.new.as_json['common']['action']['close']).to eq 'Close'
  end
end
