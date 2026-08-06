require "test_helper"

class InlineImageAttachmentRepairServiceTest < ActiveSupport::TestCase
  setup do
    @blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("embedded image"),
      filename: "image.png",
      content_type: "image/png"
    )
    @discussion = discussions(:discussion)
    @comment = Comment.create!(
      parent: @discussion,
      user: users(:user),
      body: "![embedded](#{representation_path(@blob)})",
      body_format: "md"
    )
  end

  test "dry run reports a missing attachment without changing records" do
    result = InlineImageAttachmentRepairService.repair_record(@comment, dry_run: true)

    assert_equal 1, result[:attachment_links_missing]
    assert_equal [@blob.id], result[:blob_ids_missing]
    assert_equal 0, result[:signed_ids_unresolved]
    assert_not @comment.image_files.attached?
  end

  test "repair creates a missing image attachment with group ownership" do
    updated_at = @comment.updated_at

    result = InlineImageAttachmentRepairService.repair_record(@comment, dry_run: false)

    assert_equal 1, result[:attachment_links_missing]
    attachment = @comment.reload.image_files.attachments.find_by!(blob_id: @blob.id)
    assert_equal @discussion.group.id, attachment.group_id
    assert_equal updated_at, @comment.updated_at
  end

  test "repair is idempotent" do
    InlineImageAttachmentRepairService.repair_record(@comment, dry_run: false)

    assert_no_difference "ActiveStorage::Attachment.count" do
      result = InlineImageAttachmentRepairService.repair_record(@comment, dry_run: false)
      assert_equal 0, result[:attachment_links_missing]
    end
  end

  test "repair ignores invalid signed ids" do
    @comment.update_column(
      :body,
      "![invalid](/rails/active_storage/representations/redirect/not-signed/variation/image.png)"
    )

    result = InlineImageAttachmentRepairService.repair_record(@comment, dry_run: false)

    assert_equal 0, result[:attachment_links_missing]
    assert_equal 1, result[:signed_ids_unresolved]
    assert_not @comment.image_files.attached?
  end

  test "run reports unique missing blobs and bytes" do
    stats = InlineImageAttachmentRepairService.run(dry_run: true)

    assert stats[:dry_run]
    assert_operator stats[:records_scanned], :>=, 1
    assert_operator stats[:records_repaired], :>=, 1
    assert_operator stats[:attachment_links_missing], :>=, 1
    assert_operator stats[:blobs_missing], :>=, 1
    assert_operator stats[:blob_bytes_missing], :>=, @blob.byte_size
  end

  private

  def representation_path(blob)
    Rails.application.routes.url_helpers.rails_representation_path(
      blob.representation(HasRichText::PREVIEW_OPTIONS),
      only_path: true
    )
  end
end
