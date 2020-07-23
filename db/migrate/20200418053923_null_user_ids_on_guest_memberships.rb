class NullUserIdsOnGuestMemberships < ActiveRecord::Migration[5.2]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    execute "CREATE TEMP TABLE guest_memberships (id INT, user_id INT)"
    execute "INSERT INTO guest_memberships (id, user_id) SELECT memberships.id, memberships.user_id FROM memberships LEFT OUTER JOIN groups on groups.id = memberships.group_id WHERE groups.id IS NULL"
    execute "UPDATE memberships SET user_id = null WHERE id IN (SELECT id FROM guest_memberships)"
  end
end
