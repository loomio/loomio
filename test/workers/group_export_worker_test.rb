require "test_helper"

class GroupExportWorkerTest < ActiveSupport::TestCase
  setup do
    @group = groups(:orphan_group)
    @group.discard!(actor: users(:admin))
    @requestor = users(:admin)
    @recipient_email = "records@example.com"
  end

  test "JSON export of a discarded group is sent to the selected email" do
    GroupExportWorker.perform_now([ @group.id ], @group.name, @requestor.id, @recipient_email)

    assert_equal [ @recipient_email ], ActionMailer::Base.deliveries.last.to
  end

  test "CSV export of a discarded group is sent to the selected email" do
    GroupExportCsvWorker.perform_now(@group.id, @requestor.id, @recipient_email)

    assert_equal [ @recipient_email ], ActionMailer::Base.deliveries.last.to
  end
end
