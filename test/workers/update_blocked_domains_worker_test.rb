require "test_helper"

class UpdateBlockedDomainsWorkerTest < ActiveSupport::TestCase
  setup do
    @previous = BlockedDomain.create!(name: "previous.example")
    @url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts"
  end

  test "download failure preserves the existing blocklist" do
    stub_request(:get, @url).to_raise(IOError)
    assert_raises(IOError) { UpdateBlockedDomainsWorker.perform_now }
    assert BlockedDomain.exists?(@previous.id)
  end

  test "an empty or invalid response preserves the existing blocklist" do
    stub_request(:get, @url).to_return(body: "<html>Unavailable</html>")
    assert_raises(RuntimeError) { UpdateBlockedDomainsWorker.perform_now }
    assert BlockedDomain.exists?(@previous.id)
  end

  test "failed insertion restores the previous blocklist" do
    stub_request(:get, @url).to_return(body: "0.0.0.0 next.example\n")
    BlockedDomain.stub(:create!, ->(*) { raise "insert failed" }) do
      assert_raises(RuntimeError) { UpdateBlockedDomainsWorker.perform_now }
    end
    assert BlockedDomain.exists?(@previous.id)
  end

  test "a successful refresh replaces the list and deduplicates domains" do
    stub_request(:get, @url).to_return(body: "# Hosts\n0.0.0.0 next.example\n0.0.0.0 next.example\n")
    UpdateBlockedDomainsWorker.perform_now
    assert_equal [ "next.example" ], BlockedDomain.pluck(:name)
  end
end
