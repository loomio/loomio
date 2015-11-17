require 'rails_helper'
describe Popolo::MotionsController, focus: true do

  let(:public_group) { create :group, is_visible_to_public: true, discussion_privacy_options: 'public_or_private' }
  let(:private_group) { create :group, is_visible_to_public: false }

  let(:public_discussion) { create :discussion, group: public_group, private: false }
  let(:private_discussion) { create :discussion, group: private_group }

  let(:public_motion) { create :motion, discussion: public_discussion }
  let(:private_motion) { create :motion, discussion: private_discussion }

  let(:old_vote) { create :vote, position: :abstain, motion: public_motion, user: public_motion.author, age: 1 }
  let(:yes_vote) { create :vote, position: :yes, motion: public_motion, user: public_motion.author }
  let(:no_vote) { create :vote, position: :no, motion: public_motion }

  let(:user) { create :user }

  before do
    private_motion
    old_vote; yes_vote; no_vote
  end

  describe 'index' do

    it 'returns a list of users motions if logged in' do
      private_group.users << user
      sign_in user
      get :index
      json = JSON.parse(response.body)
      motion_keys = json['motions'].map { |m| m['motion_id'] }
      expect(motion_keys).to_not include public_motion.key
      expect(motion_keys).to include private_motion.key
    end

    it 'returns a list of public motions' do
      get :index
      json = JSON.parse(response.body)
      motion_keys = json['motions'].map { |m| m['motion_id'] }
      expect(motion_keys).to include public_motion.key
      expect(motion_keys).to_not include private_motion.key
    end

    it 'conforms to the popolo motion spec' do
      get :index
      json = JSON.parse(response.body)
      motion = json['motions'][0]
      expect(motion['motion_id']).to eq public_motion.key
      expect(motion['organization_id']).to eq public_motion.group.name.parameterize
      expect(motion['creator_id']).to eq public_motion.author.name.parameterize
      expect(motion['text']).to eq public_motion.description
      expect(motion['classification']).to eq 'proposal'
      expect(motion['start_date'].to_date).to eq public_motion.created_at.to_date
      expect(motion['end_date'].to_date).to eq public_motion.closing_at.to_date
      expect(motion['requirement']).to eq 'consensus'
      expect(motion['result']).to eq public_motion.outcome
      voter_ids = motion['votes'].map { |v| v['voter_id'] }
      expect(voter_ids).to include yes_vote.author.name.parameterize
      expect(voter_ids).to include no_vote.author.name.parameterize
      voter_positions = motion['votes'].map { |v| v['option'] }
      expect(voter_positions).to include 'yes'
      expect(voter_positions).to include 'no'
      expect(voter_positions).to_not include 'abstain'
      expect(motion['counts']).to include({ 'option' => 'yes', 'value' => 1 })
      expect(motion['counts']).to include({ 'option' => 'no', 'value' => 1 })
      expect(motion['counts']).to include({ 'option' => 'abstain', 'value' => 0 })
    end

    it 'can filter by date' do
      old_motion = create :motion, discussion: public_discussion, created_at: 4.weeks.ago
      medium_motion = create :motion, discussion: public_discussion, created_at: 2.weeks.ago
      new_motion = create :motion, discussion: public_discussion, created_at: 0.weeks.ago
      get :index, since: 3.weeks.ago, until: 1.week.ago
      json = JSON.parse(response.body)
      motion_ids = json['motions'].map { |m| m['motion_id'] }
      expect(motion_ids).to_not include new_motion.key
      expect(motion_ids).to_not include old_motion.key
      expect(motion_ids).to include medium_motion.key
    end

    it 'sorts by closed at date' do
      3.times { |i| create :motion, discussion: public_discussion, created_at: i.days.ago }
      get :index
      json = JSON.parse(response.body)
      motion_dates = json['motions'].map { |m| m['date_submitted'] }
      expect(motion_dates.sort).to eq motion_dates
    end

    it 'responds to a per parameter' do
      3.times { create :motion, discussion: public_discussion, closed_at: 2.days.ago }
      get :index, per: 2
      json = JSON.parse(response.body)
      motion_ids = json['motions'].map { |m| m['motion_id'] }
      expect(motion_ids.length).to eq 2
    end

    it 'responds to a from parameter' do
      2.times { create :motion, discussion: public_discussion, closed_at: 2.days.ago }
      get :index, from: 1
      json = JSON.parse(response.body)
      motion_ids = json['motions'].map { |m| m['motion_id'] }
      expect(motion_ids).to_not include public_discussion
    end
  end

end
