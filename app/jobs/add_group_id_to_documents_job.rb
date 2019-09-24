class AddGroupIdToDocumentsJob < ActiveJob::Base
  def perform
    Document.where(group_id: nil).find_each do |document|
      document.update_column(:group_id, model.group_id) if model && model.respond_to?(:group_id)
    end
  end
end
