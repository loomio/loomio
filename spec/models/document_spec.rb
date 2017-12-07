require 'rails_helper'

describe Document do
  let(:user) { create :user }
  let(:document) { build :document }

  describe 'sync_urls!' do
    it 'can save a image urls' do
      document.file = fixture_for('images', 'strongbad.png')
      document.save
      document.sync_urls!
      expect(document.reload.url).to match /strongbad/
      expect(document.web_url).to match /strongbad/
      expect(document.thumb_url).to match /strongbad/
    end

    it 'can save non-image urls' do
      document.file = fixture_for('images', 'strongmad.pdf')
      document.save
      document.sync_urls!
      expect(document.reload.url).to match /strongmad/
      expect(document.web_url).to be_blank
      expect(document.thumb_url).to be_blank
    end
  end

  describe 'url' do
    it 'is invalid for bad urls' do
      document.url = 'notaurl'
      expect(document).to_not be_valid
    end

    it 'is valid for good urls' do
      document.url = 'https://aurl.com'
      expect(document).to be_valid
    end
  end
end
