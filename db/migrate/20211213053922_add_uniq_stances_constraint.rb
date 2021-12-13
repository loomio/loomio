class AddUniqStancesConstraint < ActiveRecord::Migration[6.1]
  def change
    res = execute("select poll_id, participant_id, count(*) from stances where latest = true and participant_id is not null group by participant_id, poll_id, latest HAVING count(*)>1;")
    res.each do |row|
      Stance.where(poll_id: row['poll_id'],
                   participant_id: row['participant_id'],
                   latest: true).first.delete
    end
    add_index :stances, [:poll_id, :participant_id, :latest], unique: true, where: "latest = true"
  end
end
