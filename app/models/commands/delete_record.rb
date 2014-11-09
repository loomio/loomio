class Commands::DeleteRecord < Command
  def initialize(record)
    @record = record
  end

  def to_json
    {type: 'delete_record',
     plural: ActiveModel::Naming.plural(@record),
     id: @record.id}
  end
end
