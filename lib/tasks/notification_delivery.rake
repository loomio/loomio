namespace :loomio do
  desc "Audit or apply legacy notification consolidation"
  task consolidate_notifications: :environment do
    require Rails.root.join("db/migrate/support/notification_consolidation_service")

    apply = ENV["APPLY"].present?
    repair = ENV["REPAIR"].present?
    batch_size = Integer(ENV.fetch("BATCH_SIZE", NotificationConsolidationService::BATCH_SIZE))
    high_water_id = ENV["HIGH_WATER_ID"]&.then { |value| Integer(value) }

    puts "#{apply ? 'Applying' : 'Auditing'} legacy notification consolidation"
    stats = NotificationConsolidationService.run!(
      dry_run: !apply,
      batch_size: batch_size,
      high_water_id: high_water_id,
      repair: repair,
      progress: lambda do |notification_id_cursor, notification_id_high_water, totals|
        puts "Processed legacy notifications through #{notification_id_cursor} of " \
             "#{notification_id_high_water}; #{totals[:receipts_processed]} receipts read"
      end
    )
    puts stats.inspect
    puts "No changes made. Set APPLY=1 to run." unless apply
  end
end
