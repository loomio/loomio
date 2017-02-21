require 'rails_helper'

describe SearchVector do
  describe 'index!' do
    let!(:discussion) { create :discussion, title: "Rabid Wombats", description: "Rendering Snafu" }
    let(:vector) { discussion.search_vector }
    let!(:another_discussion) { create :discussion }
    let!(:motion) { create :motion, discussion: discussion, name: "Wealthy Arsonists", description: "Caribou Abound" }
    let!(:comment) { create :comment, discussion: discussion, body: "Wellbeing Seminar" }
    let!(:poll) { create :poll, discussion: discussion, title: "Water Wombats", details: "Phishing Fail" }

    it 'can index multiple discussions' do
      SearchVector.index! [discussion.id, another_discussion.id]
      expect(discussion.reload.search_vector).to be_present
      expect(another_discussion.reload.search_vector).to be_present
    end

    it 'includes discussion info' do
      SearchVector.index! discussion.id
      expect(vector.search_vector).to match /rabid/
      expect(vector.search_vector).to match /wombat/
      expect(vector.search_vector).to match /render/
      expect(vector.search_vector).to match /snafu/
    end

    it 'includes motion info' do
      SearchVector.index! discussion.id
      expect(vector.search_vector).to match /wealth/
      expect(vector.search_vector).to match /arson/
      expect(vector.search_vector).to match /caribou/
      expect(vector.search_vector).to match /abound/
    end

    it 'includes comment body info' do
      SearchVector.index! discussion.id
      expect(vector.search_vector).to match /wellb/
      expect(vector.search_vector).to match /seminar/
    end

    it 'includes poll info' do
      SearchVector.index! discussion.id
      expect(vector.search_vector).to match /water/
      expect(vector.search_vector).to match /phish/
    end

  end
end
