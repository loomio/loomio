require 'rails_helper'

describe Document do
  let(:user) { create :user }
  let(:document) { build :document }

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
