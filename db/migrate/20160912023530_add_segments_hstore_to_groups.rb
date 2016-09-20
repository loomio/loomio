class AddSegmentsHstoreToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :experiences, :jsonb, null: false, default: {}.to_json
    Group.where("MOD (segment_seed, 2) = 1").update_all(experiences: {bx_choose_plan: true}.to_json)
    Group.where("MOD (segment_seed, 2) = 0").update_all(experiences: {bx_choose_plan: false}.to_json)
    remove_column :groups, :segment_seed
  end
end
