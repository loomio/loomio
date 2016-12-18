class AddPollReferences < ActiveRecord::Migration
  def change
    create_table :poll_references do |t|
      t.integer    :reference_id
      t.string     :reference_type
      t.belongs_to :poll
    end
  end
end
