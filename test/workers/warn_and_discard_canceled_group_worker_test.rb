require "test_helper"

class WarnAndDiscardCanceledGroupWorkerTest < ActiveSupport::TestCase
  test "legacy billing must confirm an effective cancellation before the group is discarded" do
    previous = ENV["LOOMIO_CANCELED_GROUP_CLEANUP_ENABLED"]
    ENV["LOOMIO_CANCELED_GROUP_CLEANUP_ENABLED"] = "1"
    group = groups(:orphan_group)
    group.add_admin!(users(:admin))
    subscription = Subscription.for!(group)
    subscription.update_columns(payment_method: "chargify", chargify_subscription_id: 123, state: "canceled")
    service_found = Object.const_defined?(:SubscriptionService)
    unless service_found
      Object.const_set(:SubscriptionService, Class.new do
        def self.chargify_get(_id)
          raise "Unexpected billing request"
        end
      end)
    end

    SubscriptionService.stub(:chargify_get, { "state" => "expired" }) do
      assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
        WarnAndDiscardCanceledGroupWorker.perform_now(group.id, subscription.id, "chargify", 123)
      end
    end
    assert group.reload.kept?

    SubscriptionService.stub(:chargify_get, { "state" => "canceled", "expires_at" => 1.day.from_now.iso8601 }) do
      WarnAndDiscardCanceledGroupWorker.perform_now(group.id, subscription.id, "chargify", 123)
    end
    assert group.reload.kept?

    SubscriptionService.stub(:chargify_get, { "state" => "canceled" }) do
      assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
        WarnAndDiscardCanceledGroupWorker.perform_now(group.id, subscription.id, "chargify", 123)
      end
    end
    assert group.reload.discarded?
  ensure
    Object.send(:remove_const, :SubscriptionService) if service_found == false
    ENV["LOOMIO_CANCELED_GROUP_CLEANUP_ENABLED"] = previous
  end
end
