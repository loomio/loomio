class RebuildAttachmentsForRichtext < ActiveRecord::Migration[5.2]
  def change
    Discussion.where(description_format: 'html').each {|d| d.build_attachments; d.save }
    Comment.where(body_format: 'html').each {|d| d.build_attachments; d.save }
    Poll.where(details_format: 'html').each {|d| d.build_attachments; d.save }
    FormalGroup.where(description_format: 'html').each {|d| d.build_attachments; d.save }
  end
end
