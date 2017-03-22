class AddIdentifierToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :identifier, :string, null: true, index: true
  end
end
