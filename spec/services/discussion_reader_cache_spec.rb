require 'rails_helper'

describe Caches::DiscussionReader do
  let(:user) { create :user }
  let(:discussion_one) { create :discussion, author: user }
  let(:discussion_two) { create :discussion, author: user }
  let(:cache) { Caches::DiscussionReader.new user: user, parents: [discussion_one, discussion_two] }

  describe 'initialize' do

    it 'intializes a discussion reader cache' do
      DiscussionReader.for(user: user, discussion: discussion_one).save
      expect(cache.send(:cache).keys).to include discussion_one.id
      expect(cache.send(:cache).keys).to_not include discussion_two.id
    end
  end

  describe 'get_for' do
    it 'returns an existing discussion reader if it exists' do
      existing = DiscussionReader.for(user: user, discussion: discussion_one)
      existing.save
      expect(cache.get_for(discussion_one)).to eq existing
    end

    it 'returns a new discussion reader if one does not exist' do
      created = cache.get_for(discussion_two)
      expect(created).to be_a DiscussionReader
      expect(created.discussion).to eq discussion_two
      expect(created.user).to eq user
    end
  end
end
