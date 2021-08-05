class ResetPriorityForOldProposalPollOptions < ActiveRecord::Migration[6.0]
  def change
    PollOption.joins(:poll).where('polls.poll_type': 'proposal', name: 'agree').update_all(priority: 0)
    PollOption.joins(:poll).where('polls.poll_type': 'proposal', name: 'abstain').update_all(priority: 1)
    PollOption.joins(:poll).where('polls.poll_type': 'proposal', name: 'disagree').update_all(priority: 2)
    PollOption.joins(:poll).where('polls.poll_type': 'proposal', name: 'block').update_all(priority: 3)
  end
end
