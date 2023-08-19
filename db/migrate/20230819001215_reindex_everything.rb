class ReindexEverything < ActiveRecord::Migration[7.0]
  def change
    if ENV['MIGRATE_DATA_ASYNC']
      GenericWorker.perform_async('SearchService', 'reindex_everything')
    else
      SearchService.reindex_everything
    end
  end
end
