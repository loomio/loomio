class AddGroupIdToDocumentsJob < ActiveJob::Base
  def perform
    Document.where(group_id: nil).find_each do |document|
      document.set_group_id
      puts "setting group id for document: ", document.id
    end
  end
end
