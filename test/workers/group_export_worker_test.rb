require "test_helper"

class GroupExportWorkerTest < ActiveSupport::TestCase
  setup do
    @group = groups(:orphan_group)
    @group.discard!(actor: users(:admin))
    @requestor = users(:admin)
    @recipient_email = "records@example.com"
  end

  test "JSON export of a discarded group is sent to the selected email" do
    GroupExportWorker.perform_now(@group.id, @requestor.id, @recipient_email)

    assert_equal [ @recipient_email ], ActionMailer::Base.deliveries.last.to
  end

  test "CSV export of a discarded group is sent to the selected email" do
    GroupExportCsvWorker.perform_now(@group.id, @requestor.id, @recipient_email)

    assert_equal [ @recipient_email ], ActionMailer::Base.deliveries.last.to
  end

  test "JSON export includes the coordinator's groups when the job runs" do
    group = groups(:group)
    requestor = users(:member_normal)
    group.add_admin!(requestor)

    GroupExportWorker.perform_now(group.id, requestor.id)

    assert_equal [requestor.email], ActionMailer::Base.deliveries.last.to
    assert_includes ActiveStorage::Blob.order(:id).last.download, group.description
  end

  { "JSON" => GroupExportWorker, "CSV" => GroupExportCsvWorker }.each do |format, worker|
    test "#{format} export is not generated after coordinator access is revoked" do
      group = groups(:group)
      requestor = users(:member_normal)
      group.add_admin!(requestor)
      MembershipService.revoke(membership: group.memberships.find_by!(user: requestor), actor: users(:admin))

      assert_no_difference ["ActionMailer::Base.deliveries.length", "ActiveStorage::Blob.count"] do
        worker.perform_now(group.id, requestor.id)
      end
    end

    test "#{format} export to a chosen email is not generated after instance admin access is removed" do
      @requestor.update!(is_admin: false)

      assert_no_difference ["ActionMailer::Base.deliveries.length", "ActiveStorage::Blob.count"] do
        worker.perform_now(@group.id, @requestor.id, @recipient_email)
      end
    end

    test "#{format} export to a chosen email is not generated for a group coordinator" do
      group = groups(:group)
      requestor = users(:member_normal)
      group.add_admin!(requestor)

      assert_no_difference ["ActionMailer::Base.deliveries.length", "ActiveStorage::Blob.count"] do
        worker.perform_now(group.id, requestor.id, @recipient_email)
      end
    end
  end

  test "HTML export renders a downloadable file and emails its link" do
    group = groups(:group)
    group.add_admin!(@requestor)

    assert_enqueued_with(job: ActiveStorage::PurgeJob, at: 1.week.from_now) do
      GroupExportHtmlWorker.perform_now(group.id, @requestor.id)
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal [@requestor.email], mail.to
    blob = ActiveStorage::Blob.order(:id).last
    assert_equal 'text/html', blob.content_type
    assert_includes blob.download, "Export for #{group.full_name}"
    assert_includes mail.body.encoded, blob.signed_id
  end

  test "HTML export is not generated after admin access is revoked" do
    group = groups(:group)
    requestor = users(:user)
    group.add_admin!(requestor)
    assert requestor.can?(:export, group)
    group.memberships.find_by!(user: requestor).update!(admin: false)
    deliveries_count = ActionMailer::Base.deliveries.length

    GroupExportHtmlWorker.perform_now(group.id, requestor.id)

    assert_equal deliveries_count, ActionMailer::Base.deliveries.length
  end
end
