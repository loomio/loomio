require 'rails_helper'

describe PollOption do
  describe 'display_name' do

    describe 'total score' do
      let(:user) { create :user }
      let(:poll) { create :poll_dot_vote }
      let(:poll_option) { poll.poll_options.first }
      let!(:old_stance) { create :stance,
        participant: user,
        latest: false,
        poll: poll,
        stance_choices_attributes: [{poll_option_id: poll_option.id, score: 1}]
      }
      let!(:new_stance) { create :stance,
        participant: user,
        latest: true,
        poll: poll,
        stance_choices_attributes: [{poll_option_id: poll_option.id, score: 2}]
      }

      it 'does not count old stances in total score' do
        poll.update_counts!
        poll_option.reload
        expect(poll_option.total_score).to eq 2
      end
    end
  end
end
