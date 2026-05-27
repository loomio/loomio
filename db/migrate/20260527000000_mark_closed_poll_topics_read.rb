class MarkClosedPollTopicsRead < ActiveRecord::Migration[8.0]
  def up
    if ENV['CANONICAL_HOST'] == 'www.loomio.com'
      say "Skipping closed poll topic read backfill on www.loomio.com"
      return
    end

    say "Starting closed poll topic read backfill..."
    stats = PollService.mark_closed_poll_topics_read
    say "Marked #{stats[:topics]} closed poll topics as read"
    say "Created #{stats[:readers_created]} topic readers"
    say "Updated #{stats[:readers_updated]} topic readers"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
