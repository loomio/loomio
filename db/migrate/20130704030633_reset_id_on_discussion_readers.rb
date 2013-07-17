class ResetIdOnDiscussionReaders < ActiveRecord::Migration
  def up
    latest_discussion_reader_id = DiscussionReader.last.id
    execute 'CREATE SEQUENCE "discussion_readers_id_seq"'
    execute "ALTER SEQUENCE discussion_readers_id_seq RESTART WITH #{latest_discussion_reader_id}"
    execute 'ALTER TABLE "discussion_readers" ALTER COLUMN "id" set DEFAULT NEXTVAL(\'discussion_readers_id_seq\'::regclass)'
  end

  def down
  end
end
