require 'rails_helper'

describe ::Tag do
  let(:tag) { create :tag }

  describe 'color' do
    it 'accepts a valid color' do
      tag.color = "#aaaaaa"
      expect(tag.valid?).to eq true
    end

    it 'accepts a three digit color' do
      tag.color = "#aaa"
      expect(tag.valid?).to eq true
    end

    it 'does not accept a color outside of hex range' do
      tag.color = "#aag"
      expect(tag.valid?).to eq false
    end

    it 'does not accept a color hash of the wrong length' do
      tag.color = "#aaaa"
      expect(tag.valid?).to eq false
    end

    it 'does not accept a value without a hash' do
      tag.color = "aaaaaa"
      expect(tag.valid?).to eq false
    end
  end
end
