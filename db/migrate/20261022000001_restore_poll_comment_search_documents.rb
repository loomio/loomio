class RestorePollCommentSearchDocuments < ActiveRecord::Migration[8.1]
  def up
    # Earlier indexing rules omitted comments below open until-closed polls.
    # Rebuild those conversations with the current comment and vote rules.
    Poll.kept.where(hide_results: :until_closed, closed_at: nil).select(:id).find_each do |poll|
      ReindexPollWorker.perform_later(poll.id)
    end
  end

  def down
    # Search documents are derived from the current application rules.
  end
end
