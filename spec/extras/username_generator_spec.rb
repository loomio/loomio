require 'rails_helper'

describe UsernameGenerator do
  describe "generate" do
    it "provides a username based on name if it exists" do
      user = build :user, name: "howdy ho"
      expect(UsernameGenerator.new(user).generate).to eq "howdyho"
    end

    it "lowercases a username" do
      user = build :user, name: "HOWDY HO"
      expect(UsernameGenerator.new(user).generate).to eq "howdyho"
    end

    it "converts non-ASCII characters" do
      user = build :user, name: "hædy ho"
      expect(UsernameGenerator.new(user).generate).to eq "haedyho"
    end

    it "applies a number-modified username if the current one is taken" do
      create :user, username: 'howdyho'
      user = build :user, name: 'howdy ho'
      expect(UsernameGenerator.new(user).generate).to eq 'howdyho1'
      user.save

      user = build :user, name: 'howdy ho'
      expect(UsernameGenerator.new(user).generate).to eq 'howdyho2'
    end
  end
end
