class AddMoreAttributesToPollOptions < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :poll_option_name_format, :string
    add_column :poll_options, :icon, :string
    add_column :poll_options, :meaning, :string
    add_column :poll_options, :prompt, :string
  end
end
