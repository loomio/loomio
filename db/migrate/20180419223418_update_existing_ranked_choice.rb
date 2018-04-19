class UpdateExistingRankedChoice < ActiveRecord::Migration[5.1]
  def change
    Poll.where(poll_type: :ranked_choice).each(&:update_stance_data)
  end
end
