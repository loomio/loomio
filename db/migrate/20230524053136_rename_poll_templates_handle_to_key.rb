class RenamePollTemplatesHandleToKey < ActiveRecord::Migration[7.0]
  def change
    rename_column :poll_templates, :handle, :key
  end
end
