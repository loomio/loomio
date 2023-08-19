require 'rails_helper'
describe API::V1::SearchController do

  let(:group) { create :group }
  let(:other_group) { create :group }
  let(:user) { create :user, name: 'normal user' }

  let!(:discussion) { create :discussion, group: group, title: 'findme' }
  let!(:comment) { create :comment, discussion: discussion, body: 'findme'}
  let!(:poll) { create :poll, discussion: discussion, title: 'findme' }
  let!(:stance) { create :stance, poll: poll, reason: 'findme', cast_at: DateTime.now, choice: poll.poll_option_names.first }
  let!(:anonymous_poll) { create :poll, discussion: discussion, title: 'findme anonymous', anonymous: true, closed_at: nil, closing_at: 4.days.from_now }
  let!(:anonymous_stance) { create :stance, poll: anonymous_poll, reason: 'findme anonymous', cast_at: DateTime.now, choice: anonymous_poll.poll_option_names.first }
  let!(:hidden_open_poll) { create :poll, discussion: discussion, title: 'findme', closed_at: nil, closing_at: 4.days.from_now, hide_results: :until_closed  }
  let!(:hidden_open_stance) { create :stance, poll: hidden_open_poll, reason: 'findme', cast_at: DateTime.now, choice: hidden_open_poll.poll_option_names.first }
  let!(:outcome) { create :outcome, poll: poll, statement: 'findme' }

  let!(:discarded_discussion) { create :discussion, group: group, title: "findme", discarded_at: DateTime.now }
  let!(:discarded_comment) { create :comment, discussion: discarded_discussion, body: 'findme', discarded_at: DateTime.now}
  let!(:discarded_poll) { create :poll, discussion: discarded_discussion, title: 'findme', discarded_at: DateTime.now }
  let!(:discarded_stance) { create :stance, poll: discarded_poll, reason: 'findme', cast_at: nil}
  let!(:discarded_outcome) { create :outcome, poll: discarded_poll, statement: 'findme' }

  let!(:io_discussion) { create :discussion, group: nil, title: 'findme' }
  let!(:io_comment) { create :comment, discussion: io_discussion, body: 'findme'}
  let!(:io_poll) { create :poll, discussion: io_discussion, title: 'findme' }
  let!(:io_stance) { create :stance, poll: io_poll, reason: 'findme', cast_at: DateTime.now, choice: poll.poll_option_names.first }
  let!(:io_outcome) { create :outcome, poll: io_poll, statement: 'findme' }

  let!(:other_discussion) { create :discussion, group: other_group, title: 'findme' }
  let!(:other_comment) { create :comment, discussion: other_discussion, body: 'findme'}
  let!(:other_poll) { create :poll, discussion: other_discussion, title: 'findme' }
  let!(:other_stance) { create :stance, poll: other_poll, reason: 'findme', cast_at: DateTime.now, choice: poll.poll_option_names.first }
  let!(:other_outcome) { create :outcome, poll: other_poll, statement: 'findme' }

  let!(:guest_discussion) { create :discussion, group: other_group, title: 'findme' }
  let!(:guest_comment) { create :comment, discussion: guest_discussion, body: 'findme'}
  let!(:guest_poll) { create :poll, discussion: guest_discussion, title: 'findme' }
  let!(:guest_stance) { create :stance, poll: guest_poll, reason: 'findme', cast_at: DateTime.now, choice: poll.poll_option_names.first }
  let!(:guest_outcome) { create :outcome, poll: guest_poll, statement: 'findme' }

  describe 'search' do
    before do
      group.add_member!(user)
      io_discussion.add_guest!(user, discussion.author)
      guest_discussion.add_guest!(user, discussion.author)
      sign_in user
    end

    it 'returns any visible records' do
            get :index, params: {query: 'findme'}
      results = JSON.parse(response.body)['search_results']

      # check that each item is returned
      expect(results.filter do |r| 
        r['searchable_type'] == 'Discussion' && r['searchable_id'] == discussion.id
      end.size).to eq 1

      expect(results.filter do |r| 
        r['searchable_type'] == 'Discussion' && r['searchable_id'] == io_discussion.id
      end.size).to eq 1

      expect(results.filter do |r| 
        r['searchable_type'] == 'Discussion' && r['searchable_id'] == guest_discussion.id
      end.size).to eq 1

      # check that no other items are returned
      type_counts = {}
      results.map do |result|
        type_counts[result['searchable_type']] ||= 0
        type_counts[result['searchable_type']] += 1
      end

      expect(type_counts['Discussion']).to eq 3
      expect(type_counts['Comment']).to eq 3
      expect(type_counts['Poll']).to eq 5
      expect(type_counts['Stance']).to eq 3
      expect(type_counts['Outcome']).to eq 3
    end

    it 'returns group records' do
      get :index, params: {query: 'findme', group_id: group.id}
      results = JSON.parse(response.body)['search_results']

      # check that each item is returned
      expect(results.filter do |r| 
        r['searchable_type'] == 'Discussion' && r['searchable_id'] == discussion.id
      end.size).to eq 1

      expect(results.filter do |r| 
        r['searchable_type'] == 'Comment' && r['searchable_id'] == comment.id
      end.size).to eq 1

      expect(results.filter do |r| 
        r['searchable_type'] == 'Poll' && r['searchable_id'] == poll.id
      end.size).to eq 1

      expect(results.filter do |r| 
        r['searchable_type'] == 'Stance' && r['searchable_id'] == stance.id
      end.size).to eq 1

      expect(results.filter do |r| 
        r['searchable_type'] == 'Outcome' && r['searchable_id'] == outcome.id
      end.size).to eq 1

      # check that no other items are returned
      type_counts = {}
      results.map do |result|
        type_counts[result['searchable_type']] ||= 0
        type_counts[result['searchable_type']] += 1
      end

      expect(type_counts['Discussion']).to eq 1
      expect(type_counts['Comment']).to eq 1
      expect(type_counts['Poll']).to eq 3
      expect(type_counts['Stance']).to eq 1
      expect(type_counts['Outcome']).to eq 1
    end

    it 'does not return other group records' do
      get :index, params: {query: 'findme', group_id: other_group.id}
      results = JSON.parse(response.body)['search_results']

      # check that each item is returned
      expect(results.filter do |r| 
        r['searchable_type'] == 'Discussion' && r['searchable_id'] == other_discussion.id
      end.size).to eq 0

      expect(results.filter do |r| 
        r['searchable_type'] == 'Comment' && r['searchable_id'] == other_comment.id
      end.size).to eq 0

      expect(results.filter do |r| 
        r['searchable_type'] == 'Poll' && r['searchable_id'] == other_poll.id
      end.size).to eq 0

      expect(results.filter do |r| 
        r['searchable_type'] == 'Stance' && r['searchable_id'] == other_stance.id
      end.size).to eq 0

      expect(results.filter do |r| 
        r['searchable_type'] == 'Outcome' && r['searchable_id'] == other_outcome.id
      end.size).to eq 0

      # check that no other items are returned
      type_counts = {}
      results.map do |result|
        type_counts[result['searchable_type']] ||= 0
        type_counts[result['searchable_type']] += 1
      end

      expect(type_counts['Discussion']).to eq nil
      expect(type_counts['Comment']).to eq nil
      expect(type_counts['Poll']).to eq nil
      expect(type_counts['Stance']).to eq nil
      expect(type_counts['Outcome']).to eq nil
    end

    it 'returns invite-only records' do
      get :index, params: {query: 'findme', group_id: 0}
      results = JSON.parse(response.body)['search_results']

      # check that each item is returned
      expect(results.filter do |r| 
        r['searchable_type'] == 'Discussion' && r['searchable_id'] == io_discussion.id
      end.size).to eq 1

      expect(results.filter do |r| 
        r['searchable_type'] == 'Comment' && r['searchable_id'] == io_comment.id
      end.size).to eq 1

      expect(results.filter do |r| 
        r['searchable_type'] == 'Poll' && r['searchable_id'] == io_poll.id
      end.size).to eq 1

      expect(results.filter do |r| 
        r['searchable_type'] == 'Stance' && r['searchable_id'] == io_stance.id
      end.size).to eq 1

      expect(results.filter do |r| 
        r['searchable_type'] == 'Outcome' && r['searchable_id'] == io_outcome.id
      end.size).to eq 1

      # check that no other items are returned
      type_counts = {}
      results.map do |result|
        type_counts[result['searchable_type']] ||= 0
        type_counts[result['searchable_type']] += 1
      end

      expect(type_counts['Discussion']).to eq 1
      expect(type_counts['Comment']).to eq 1
      expect(type_counts['Poll']).to eq 1
      expect(type_counts['Stance']).to eq 1
      expect(type_counts['Outcome']).to eq 1
    end

    # it 'returns guest discussions when group_id' do
    # end

    # it 'does not return hidden stances' do
    # end

  end
end
