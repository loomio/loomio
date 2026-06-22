class AddCommentLengthMaxToTopicsAndTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :topics, :comment_length_max, :integer
    add_column :discussion_templates, :comment_length_max, :integer
    add_column :poll_templates, :comment_length_max, :integer
  end
end
