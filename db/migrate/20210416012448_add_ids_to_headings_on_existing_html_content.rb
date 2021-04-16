class AddIdsToHeadingsOnExistingHtmlContent < ActiveRecord::Migration[6.0]
  def change
    AddHeadingIdsWorker.perform_async
  end
end
