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

  test "preserves existing regular attachments when string-key files are nil" do
    blob = create_blob("existing file")
    @comment.files.attach(blob)

    @comment.assign_attributes_and_files("body" => "Updated comment", "files" => nil)
    @comment.save!

    assert_equal [blob.id], @comment.reload.files.blobs.ids
  end

  test "removes existing regular attachments when files are explicitly empty" do
    blob = create_blob("existing file")
    @comment.files.attach(blob)

    @comment.assign_attributes_and_files(body: "Updated comment", files: [])
    @comment.save!

    assert_empty @comment.reload.files.blobs
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

  test "detects additions on templates without a topic or actor" do
    template = DiscussionTemplate.new(description: "Text only", description_format: "md")
    assert_not template.attachments_added?

    template.description = "![image](https://example.com/image.png)"
    assert template.attachments_added?

    template.description = "Text only"
    template.files = [create_blob("template attachment")]
    assert template.attachments_added?
  end

  test "distinguishes retained and removed files from additions without assigning them" do
    existing_blob = create_blob("existing file")
    added_blob = create_blob("added file")
    @comment.files.attach(existing_blob)

    assert_not @comment.attachments_added?("files" => [existing_blob.signed_id])
    assert_not @comment.attachments_added?(files: [])
    assert @comment.attachments_added?(files: [existing_blob.signed_id, added_blob.signed_id])
    assert @comment.attachments_added?(image_files: [added_blob.signed_id])
    assert_equal [existing_blob.id], @comment.reload.files.blobs.ids
    assert_empty @comment.image_files
  end

  test "compares rendered media across formats and pending text edits" do
    @comment.update!(body: "![image](https://example.com/image.png)", body_format: "md")

    assert_not @comment.attachments_added?(body: '<img src="https://example.com/image.png">', body_format: "html")
    assert_not @comment.attachments_added?(body: "Text only")

    @comment.body = "![image](https://example.com/another.png)"
    assert @comment.attachments_added?
    assert_includes @comment.reload.body, "https://example.com/image.png"
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
