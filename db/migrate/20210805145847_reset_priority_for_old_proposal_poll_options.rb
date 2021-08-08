class ResetPriorityForOldProposalPollOptions < ActiveRecord::Migration[6.0]
  def change
    # PollOption.joins(:poll).where('polls.poll_type': 'proposal', name: 'agree', priority: 0).update_all(priority: 0)
    PollOption.joins(:poll).where('polls.poll_type': 'proposal', name: 'abstain', priority: 0).update_all(priority: 1)
    PollOption.joins(:poll).where('polls.poll_type': 'proposal', name: 'disagree', priority: 0).update_all(priority: 2)
    PollOption.joins(:poll).where('polls.poll_type': 'proposal', name: 'block', priority: 0).update_all(priority: 3)
  end
end
