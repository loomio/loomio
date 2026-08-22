namespace :loomio do
  desc "Audit or apply the post-deploy notification delivery field backfill"
  task backfill_notification_delivery_fields: :environment do
    apply = ENV["APPLY"].present?
    rebuild_index = ENV["REBUILD_INDEX"].present?
    batch_size = Integer(ENV.fetch("BATCH_SIZE", NotificationDeliveryBackfillService::BATCH_SIZE))
    high_water_id = ENV["HIGH_WATER_ID"]&.then { |value| Integer(value) }

    puts "#{apply ? 'Applying' : 'Auditing'} notification delivery field backfill"
    if apply && rebuild_index
      puts "Maintenance mode: notification writers must remain stopped while the deduplication index is rebuilt"
    end
    stats = NotificationDeliveryBackfillService.run!(
      dry_run: !apply,
      batch_size: batch_size,
      high_water_id: high_water_id,
      rebuild_index: rebuild_index,
      progress: lambda do |phase, id_after, id_finish, totals|
        if phase == :duplicates
          puts "Normalized notification event ids after #{id_after} through #{id_finish}; " \
               "#{totals[:removed_notifications]} duplicate rows removed"
        else
          puts "Processed notification ids after #{id_after} through #{id_finish}; " \
               "#{totals[:notifications_updated]} rows updated"
        end
      end
    )
    puts stats.inspect
    puts "No changes made. Drain old notification workers, then set APPLY=1 to run." unless apply
  end
end
