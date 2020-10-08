class RebuildAttachmentsForRichtext < ActiveRecord::Migration[5.2]
  def change
    Discussion.where(description_format: 'html').each {|d| d.save }
    Comment.where(body_format: 'html').each {|d| d.save }
    Poll.where(details_format: 'html').each {|d| d.save }
    FormalGroup.where(description_format: 'html').each {|d| d.save }
  end
end
