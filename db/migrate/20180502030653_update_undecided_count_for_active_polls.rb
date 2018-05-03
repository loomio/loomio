class UpdateUndecidedCountForActivePolls < ActiveRecord::Migration[5.1]
  def change
    Poll.active.each(&:update_undecided_count)
  end
end
