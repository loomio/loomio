class AddAnnounceableMembersCountToDiscussions < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :announceable_members_count, :integer

    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'

    execute 'CREATE TEMP table reader_temp (reader_id INT, user_id INT, group_id INT, volume INT)'
    execute 'CREATE INDEX reader_id_idx ON reader_temp (reader_id)'
    execute 'INSERT INTO reader_temp (
        SELECT dr.id as reader_id,
               dr.user_id as user_id,
               d.group_id as group_id
        FROM discussion_readers dr LEFT JOIN discussions d on dr.discussion_id = d.id
      )'

    execute 'UPDATE reader_temp t SET volume = (
      SELECT volume FROM memberships WHERE user_id = t.user_id and group_id = t.group_id
    )'

    max = DiscussionReader.order('id desc').limit(1).pluck(:id).first
    i = 0
    step = 10000
    while i < max do
      execute(
        "UPDATE discussion_readers dr SET volume = (
          SELECT volume FROM reader_temp WHERE reader_id = dr.id
        ) where dr.volume is null and dr.id > #{i} and dr.id <= #{i+step}")
      i = i + step
    end

  end
end
