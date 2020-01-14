class AddGroupIdToDocumentsWorker
  include Sidekiq::Worker

  def perform
    Document.where(group_id: nil).find_each do |document|
      document.update_column(:group_id, document.model.group_id) if document.model && document.model.respond_to?(:group_id)
    end
  end
end
