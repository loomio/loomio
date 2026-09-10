# Migration-owned cleanup for tag records whose required parent was removed by
# legacy callbackless deletion. Delete taggings first so the cleanup also works
# before the taggings foreign key has been installed.
module TagReferenceIntegrityCleanup
  def self.run!(connection)
    taggings = connection.execute(<<~SQL).cmd_tuples
      DELETE FROM taggings
      WHERE tag_id IS NULL
         OR NOT EXISTS (SELECT 1 FROM tags WHERE tags.id = taggings.tag_id)
    SQL

    tags = connection.execute(<<~SQL).cmd_tuples
      DELETE FROM tags
      WHERE group_id IS NULL
         OR NOT EXISTS (SELECT 1 FROM groups WHERE groups.id = tags.group_id)
    SQL

    { taggings: taggings, tags: tags }
  end
end
