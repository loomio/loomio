require "test_helper"
require_relative "../support/access_volume_matrix"

class MigrateUserRollbackTest < ActiveSupport::TestCase
  include AccessVolumeMatrix

  MERGE_PAIRS = [
    %i[member_loud member_quiet],
    %i[reader_quiet reader_loud],
    %i[guest_loud guest_quiet],
    %i[guest_admin_normal guest_normal],
    %i[former_guest_loud guest_loud],
    %i[guest_loud former_guest_loud],
    %i[inactive_guest_loud guest_normal]
  ].freeze

  MERGE_PAIRS.each do |source_role, destination_role|
    %i[duplicates redaction].each do |failure_stage|
      test "#{source_role} into #{destination_role} preserves both accounts and the matrix after #{failure_stage} failure" do
        source = users(source_role)
        destination = users(destination_role)
        blob = ActiveStorage::Blob.create!(key: "merge-avatar-#{SecureRandom.hex(8)}", filename: "avatar.png",
          content_type: "image/png", byte_size: 1, checksum: "1B2M2Y8AsgTpgAmY7PhCfg==", service_name: "test", metadata: { analyzed: true })
        avatar = ActiveStorage::Attachment.create!(record: source, name: "uploaded_avatar", blob: blob)
        source.reload
        before = access_volume_matrix
        accounts = [ source, destination ].to_h { |user| [ user.id, user.attributes ] }
        references = [ Membership, TopicReader ].to_h { |model| [ model, model.order(:id).map(&:attributes) ] }
        sessions = [ source, destination ].map { |user| user.sessions.create!(user_agent: "Matrix browser", ip_address: "127.0.0.1") }
        tokens = [ source, destination ].map { |user| LoginToken.create!(user: user) }
        worker = MigrateUserWorker.new
        redact = RedactUserWorker.method(:perform_now)

        NewsletterService.stub(:unsubscribe, ->(*) { flunk "rolled-back merge must not unsubscribe" }) do
          assert_no_enqueued_jobs do
            if failure_stage == :duplicates
              worker.stub(:operations, -> { raise "failure after duplicate removal" }) do
                assert_raises(RuntimeError) { worker.perform(source.id, destination.id) }
              end
            else
              RedactUserWorker.stub(:perform_now, ->(*args) { redact.call(*args); raise "failure after redaction" }) do
                assert_raises(RuntimeError) { worker.perform(source.id, destination.id) }
              end
            end
          end
        end

        accounts.each { |id, expected| assert_equal expected, User.find(id).attributes }
        references.each { |model, expected| assert_equal expected, model.order(:id).map(&:attributes), model.name }
        sessions.each { |session| assert_equal session.user_id, session.reload.user_id }
        tokens.each { |token| assert_equal token.user_id, token.reload.user_id }
        assert_equal blob.id, avatar.reload.blob_id
        assert ActiveStorage::Blob.exists?(blob.id)
        assert_access_volume_matrix_unchanged(before)
      end
    end
  end

  test "merging an account into itself cannot delete its access or credentials" do
    user = users(:member_loud)
    original = user.attributes
    memberships = user.all_memberships.order(:id).map(&:attributes)
    readers = user.topic_readers.order(:id).map(&:attributes)
    token = LoginToken.create!(user: user)

    assert_no_enqueued_jobs do
      assert_raises(ArgumentError) { MigrateUserWorker.new.perform(user.id, user.id.to_s) }
    end

    assert_equal original, user.reload.attributes
    assert_equal memberships, user.all_memberships.reload.order(:id).map(&:attributes)
    assert_equal readers, user.topic_readers.reload.order(:id).map(&:attributes)
    assert_equal user.id, token.reload.user_id
  end
end
