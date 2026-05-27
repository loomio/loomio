class BackfillStandalonePollStanceThreadItems < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    if ENV['CANONICAL_HOST'] == 'www.loomio.com'
      say "Skipping standalone poll stance backfill on #{ENV['CANONICAL_HOST']}"
      return
    end

    stats = PollService.backfill_standalone_poll_stance_thread_items(mark_closed_read: true)

    say "Attached #{stats[:events]} stance events to #{stats[:topics]} standalone poll topics"
    say "Repaired #{stats[:repair_topics]} standalone poll topics"
    say "Marked #{stats[:closed_read][:topics]} closed poll topics as read"
    say "Created #{stats[:closed_read][:readers_created]} topic readers"
    say "Updated #{stats[:closed_read][:readers_updated]} topic readers"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
