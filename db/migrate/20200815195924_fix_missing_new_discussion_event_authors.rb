class FixMissingNewDiscussionEventAuthors < ActiveRecord::Migration[5.2]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    execute("UPDATE events
             SET user_id = discussions.author_id
             FROM discussions
             WHERE events.kind = 'new_discussion'
               AND events.eventable_id = discussions.id")
  end
end
