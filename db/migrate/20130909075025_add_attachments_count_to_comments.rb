class AddAttachmentsCountToComments < ActiveRecord::Migration
  class Comment < ActiveRecord::Base
    has_many :attachments
  end

  def up
    add_column :comments, :attachments_count, :integer, null: false, default: 0

    Comment.reset_column_information
    Comment.find_each do |comment|
      puts comment.id if comment.id % 100 == 0
      comment.update_attribute(:attachments_count, comment.attachments.count)
    end
  end

  def down
    remove_column :comments, :attachments_count
  end
end
