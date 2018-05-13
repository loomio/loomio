class UpdateUndecidedCountForActivePolls < ActiveRecord::Migration[5.1]
  class UpdateUndecidedCountJob
    def perform
      Poll.reset_column_information
      Poll.active.find_each(&:update_undecided_count)
    end
  end

  def change
    # Group.reset_column_information
    # Delayed::Job.enqueue UpdateUndecidedCountJob.new
  end
end
