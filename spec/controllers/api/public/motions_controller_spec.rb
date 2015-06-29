require 'rails_helper'
describe API::Public::MotionsController do

  let(:public_group) { create :group, is_visible_to_public: true }
  let(:private_group) { create :group, is_visible_to_public: false }

  let(:public_discussion) { create :discussion, group: public_group }
  let(:private_discussion) { create :discussion, group: private_group }

  let(:public_motion) { create :motion, discussion: public_discussion }
  let(:private_motion) { create :motion, discussion: private_discussion }

  before { public_motion; private_motion }

  describe 'index' do

    it 'returns a list of public motions' do
      get :index
      json = JSON.parse(response.body)
      motion_ids = json['motions'].map { |m| m['id'] }
      expect(motion_ids).to include public_motion.id
      expect(motion_ids).to_not include private_motion.id
    end

    it 'conforms to the popolo motion spec' do
      get :index
      json = JSON.parse(response.body)
      motion = json['motions'][0]
      expect(motion['organization_id']).to eq motion.group.name.parameterize
      expect(motion['creator_id']).to eq motion.author.name.parameterize
      expect(motion['text']).to eq motion.description
      expect(motion['classification']).to eq 'proposal'
      expect(motion['date']).to eq motion.created_at
      expect(motion['requirement']).to eq 'consensus'
      expect(motion['result']).to eq motion.outcome
      # TODO: vote counts
    end

    it 'can filter by date' do
      old_motion = create :motion, discussion: public_discussion, created_at: 4.weeks.ago
      medium_motion = create :motion, discussion: public_discussion, created_at: 2.weeks.ago
      new_motion = create :motion, discussion: public_discussion, created_at: 0.weeks.ago
      get :index, since: 3.weeks.ago, till: 1.week.ago
      json = JSON.parse(response.body)
      motion_ids = json['motions'].map { |m| m['id'] }
      expect(motion_ids).to_not include new_motion.id
      expect(motion_ids).to_not include old_motion.id
      expect(motion_ids).to include medium_motion.id
    end

    it 'sorts by closed at date' do
      3.times { |i| create :motion, discussion: public_discussion, created_at: i.days.ago }
      get :index
      json = JSON.parse(response.body)
      motion_dates = json['motions'].map { |m| m['date_submitted'] }
      expect(motion_dates.sort).to eq motion_dates
    end

    it 'responds to a per parameter' do
      2.times { create :motion, discussion: public_discussion, closed_at: 2.days.ago }
      get :index, per: 2
      json = JSON.parse(response.body)
      motion_ids = json['motions'].map { |m| m['id'] }
      expect(motion_ids.length).to eq 2
    end

    it 'responds to a from parameter' do
      2.times { create :motion, discussion: public_discussion, closed_at: 2.days.ago }
      get :index, from: 1
      json = JSON.parse(response.body)
      motion_ids = json['motions'].map { |m| m['id'] }
      expect(motion_ids).to_not include public_discussion
    end
  end

end
