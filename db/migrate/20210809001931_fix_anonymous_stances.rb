class FixAnonymousStances < ActiveRecord::Migration[6.0]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    poll_ids = Poll.where(anonymous: true).where("closed_at is not null").pluck(:id)
    Stance.where(poll_id: poll_ids).update_all(latest: false)
    Stance.where(poll_id: poll_ids).where('cast_at is not null').update_all(latest: true)
    Stance.where(poll_id: poll_ids).where('cast_at is not null').find_each(&:update_option_scores!)
    Poll.where(id: poll_ids).find_each(&:update_counts!)
  end
end
