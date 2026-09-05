require "test_helper"
require Rails.root.join("db/migrate/20260505142921_drop_documents_table")

class DropDocumentsPreservationTest < ActiveSupport::TestCase
  test "same-named distinct legacy files both remain attached while identical blobs are deduplicated" do
    connection = ActiveRecord::Base.connection
    connection.execute("CREATE TEMPORARY TABLE documents (id bigint PRIMARY KEY) ON COMMIT DROP")
    parent = discussions(:discussion)
    blobs = 2.times.map do |index|
      ActiveStorage::Blob.create!(key: "legacy-#{SecureRandom.hex(8)}", filename: "minutes.pdf", byte_size: index + 1,
        checksum: "1B2M2Y8AsgTpgAmY7PhCfg==", service_name: ActiveStorage::Blob.service.name)
    end
    ActiveStorage::Attachment.create!(record: parent, name: "files", blob: blobs.first)
    [ blobs.last, blobs.last ].each_with_index do |blob, index|
      document_id = 123456 + index
      connection.execute("INSERT INTO documents(id) VALUES (#{document_id})")
      ActiveStorage::Attachment.insert_all!([ { record_type: "Document", record_id: document_id, name: "file", blob_id: blob.id, created_at: Time.current } ])
      doc = Struct.new(:id, :file_file_name).new(document_id, "minutes.pdf")

      DropDocumentsTable.new.send(:attach_and_finalize, parent, doc, blob)

      assert ActiveStorage::Attachment.exists?(record: parent, blob_id: blob.id)
      assert_equal 0, connection.select_value("SELECT count(*) FROM documents WHERE id = #{document_id}")
    end
    assert_equal blobs.map(&:id).sort, parent.files_attachments.reload.pluck(:blob_id).sort
  end
end
