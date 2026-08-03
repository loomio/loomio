require "test_helper"

class HasRichTextTest < ActiveSupport::TestCase
  setup do
    @comment = Comment.create!(
      parent: discussions(:discussion),
      user: users(:user),
      body: "A comment",
      body_format: "md"
    )
  end

  test "preserves existing inline image attachments when image files are empty" do
    blob = create_blob("existing image")
    @comment.image_files.attach(blob)

    @comment.assign_attributes_and_files(body: "Updated comment", image_files: [])
    @comment.save!

    assert_equal [blob.id], @comment.reload.image_files.blobs.ids
  end

  test "preserves existing inline image attachments with string parameter keys" do
    blob = create_blob("existing image")
    @comment.image_files.attach(blob)

    @comment.assign_attributes_and_files("body" => "Updated comment", "image_files" => [])
    @comment.save!

    assert_equal [blob.id], @comment.reload.image_files.blobs.ids
  end

  test "preserves existing inline image attachments when image files are partial" do
    existing_blob = create_blob("existing image")
    added_blob = create_blob("added image")
    @comment.image_files.attach(existing_blob)

    @comment.assign_attributes_and_files(
      body: "Updated comment",
      image_files: [added_blob.signed_id]
    )
    @comment.save!

    assert_equal [existing_blob.id, added_blob.id].sort, @comment.reload.image_files.blobs.ids.sort
  end

  test "attaches a blob referenced by an inline representation path" do
    blob = create_blob("embedded image")
    representation_path = Rails.application.routes.url_helpers.rails_representation_path(
      blob.representation(HasRichText::PREVIEW_OPTIONS),
      only_path: true
    )

    @comment.assign_attributes_and_files(
      body: "![embedded image](#{representation_path})",
      image_files: []
    )
    @comment.save!

    assert_equal [blob.id], @comment.reload.image_files.blobs.ids
  end

  test "attaches a blob referenced by an inline blob path" do
    blob = create_blob("embedded media")
    blob_path = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)

    @comment.assign_attributes_and_files(body: %(<audio src="#{blob_path}"></audio>))
    @comment.save!

    assert_equal [blob.id], @comment.reload.image_files.blobs.ids
  end

  test "ignores an invalid signed id embedded in rich text" do
    @comment.assign_attributes_and_files(
      body: "![missing](/rails/active_storage/representations/redirect/not-signed/variation/file.png)",
      image_files: []
    )

    assert @comment.save
    assert_empty @comment.reload.image_files.blobs
  end

  private

  def create_blob(contents)
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(contents),
      filename: "image.png",
      content_type: "image/png"
    )
  end
end
