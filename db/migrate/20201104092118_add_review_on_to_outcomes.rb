class AddReviewOnToOutcomes < ActiveRecord::Migration[5.2]
  def change
    add_column :outcomes, :review_on, :date, null: true
  end
end
