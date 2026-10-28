# Runs separately from the poll column renames so the polls table lock is
# released before notifications are scanned.
class RenameVoterStatusAudiences < ActiveRecord::Migration[8.1]
  AUDIENCES = {'decided_voters' => 'voters_cast', 'undecided_voters' => 'voters_uncast'}.freeze

  def up
    AUDIENCES.each { |before, after| rename_audience(before, after) }
  end

  def down
    AUDIENCES.each { |before, after| rename_audience(after, before) }
  end

  private

  def rename_audience(before, after)
    %w[notifications discussion_templates].each do |table|
      execute <<~SQL
        UPDATE #{table}
        SET recipient_audience = #{connection.quote(after)}
        WHERE recipient_audience = #{connection.quote(before)}
      SQL
    end
  end
end
