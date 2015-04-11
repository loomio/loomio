require 'rails_helper'

describe FayeHelper do
  context 'valid_channel?' do
    context "discussions" do
      it "accepts valid" do
        expect(helper.valid_channel?('discussion-2aw2d')).to be true
      end

      it "rejects invalid" do
        expect(helper.valid_channel?('discussion-')).to be false
      end
    end

    context 'notifications' do
      it "accepts valid " do
        expect(helper.valid_channel?('notifications')).to be true
      end
    end

    it "rejects invalid" do
      expect(helper.valid_channel?('groups')).to be false
    end
  end
end
