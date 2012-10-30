class ChangeColumnExpectedSizeToStringInGroupRequest < ActiveRecord::Migration
  class GroupRequest < ActiveRecord::Base
  end
  def up
    rename_column :group_requests, :expected_size, :temp_column
    add_column :group_requests, :expected_size, :string
    GroupRequest.reset_column_information
    GroupRequest.all.each do |request|
      request.expected_size = request.temp_column.to_s
      request.save
    end
    remove_column :group_requests, :temp_column
  end

  def down
    rename_column :group_requests, :expected_size, :temp_column
    change_column :group_requests, :expected_size, :integer
    GroupRequest.reset_column_information
    GroupRequest.all.each do |request|
      request.expected_size = request.temp_column.to_i
      request.save
    end
    remove_column :group_requests, :temp_column
  end
end
