class QueueTagNameNormalization < ActiveRecord::Migration[8.0]
  def up
    NormalizeTagNamesWorker.set(wait: 1.hour).perform_later
  end

  def down
    # No-op. The cleanup is idempotent and intentionally not reversed.
  end
end
