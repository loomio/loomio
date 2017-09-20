class API::DocumentsController < API::RestfulController
  private

  def accessible_records
    (load_and_authorize(:discussion, optional: true) || load_and_authorize(:group)).documents
  end
end
