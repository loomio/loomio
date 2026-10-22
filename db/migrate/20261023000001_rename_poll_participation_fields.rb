class RenamePollParticipationFields < ActiveRecord::Migration[8.1]
  def up
    rename_column :polls, :voters_count, :voters_eligible_count
    rename_column :polls, :undecided_voters_count, :votes_uncast_count
    rename_column :polls, :stance_counts, :option_score_totals
    rename_audiences('decided_voters', 'voters_cast')
    rename_audiences('undecided_voters', 'voters_uncast')
  end

  def down
    rename_audiences('voters_cast', 'decided_voters')
    rename_audiences('voters_uncast', 'undecided_voters')
    rename_column :polls, :option_score_totals, :stance_counts
    rename_column :polls, :votes_uncast_count, :undecided_voters_count
    rename_column :polls, :voters_eligible_count, :voters_count
  end

  private

  def rename_audiences(before, after)
    %w[notifications discussion_templates].each do |table|
      execute <<~SQL
        UPDATE #{table}
        SET recipient_audience = #{connection.quote(after)}
        WHERE recipient_audience = #{connection.quote(before)}
      SQL
    end
  end
end
