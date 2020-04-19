class CorrectStancesCount < ActiveRecord::Migration[5.2]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    execute "UPDATE polls SET stances_count = (select count(id) from stances where poll_id = polls.id and latest = TRUE)"
    execute "UPDATE polls SET undecided_count = (select count(id) from stances where poll_id = polls.id and latest = TRUE and cast_at IS NULL)"
  end
end
