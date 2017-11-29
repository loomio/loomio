require 'rails_helper'

describe Document do
  let(:document) { build :document }

  describe 'file' do
    it 'can save a files urls' do
      document.file = fixture_for('images', 'strongbad.png')
      document.save
      expect(document.reload.url).to match /strongbad/
      expect(document.web_url).to match /strongbad/
      expect(document.thumb_url).to match /strongbad/
    end
  end
end
