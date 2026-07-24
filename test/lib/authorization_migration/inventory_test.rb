require "test_helper"
require "tmpdir"
require "authorization_migration/inventory"

class AuthorizationMigration::InventoryTest < ActiveSupport::TestCase
  test "new production actions are invalid until the tracker is updated" do
    with_inventory do |inventory, root|
      create_controller(root, "api/v1/polls")
      route = build_route(root, controller: "api/v1/polls", action: "index")

      result = inventory.check(routes: [route])

      assert_equal 2, result.exit_status
      assert_equal [route.route_key], result.routes_untracked
      assert_includes result.trackers_invalid, "api/v1/polls#index: missing action tracker"
    end
  end

  test "update creates a tracker for every first-party production action" do
    with_inventory do |inventory, root|
      create_controller(root, "api/v1/polls")
      routes = [
        build_route(root, controller: "api/v1/polls", action: "index"),
        build_route(root, controller: "api/v1/polls", action: "show", path: "/api/v1/polls/:id")
      ]

      result = inventory.update_with_routes_for_test!(routes)

      assert_equal 1, result.exit_status, result.inspect
      assert_equal 2, result.remaining_count
      assert_equal 2, result.status_counts.fetch("inventoried")
      tracker = root.join("docs/authorization_migration/controllers/api_v1_polls_controller.txt").read
      assert_includes tracker, "[action index]"
      assert_includes tracker, "action_id = api/v1/polls#index"
      assert_includes tracker, "[action show]"
    end
  end

  test "complete requires authorization and test evidence" do
    with_inventory do |inventory, root|
      create_controller(root, "api/v1/polls")
      route = build_route(root, controller: "api/v1/polls", action: "index")
      inventory.update_with_routes_for_test!([route])
      tracker_path = root.join("docs/authorization_migration/controllers/api_v1_polls_controller.txt")
      tracker_path.write(tracker_path.read.sub("status = inventoried", "status = complete"))

      result = inventory.check(routes: [route])

      assert_equal 2, result.exit_status
      assert result.trackers_invalid.any? { |error| error.include?("complete without") }
    end
  end

  test "status uses the snapshot without loading live routes" do
    with_inventory do |inventory, root|
      create_controller(root, "api/v1/polls")
      route = build_route(root, controller: "api/v1/polls", action: "index")
      inventory.update_with_routes_for_test!([route])
      inventory.define_singleton_method(:routes_live) { raise "should not load Rails routes" }

      result = inventory.status

      assert_equal 1, result.exit_status
      assert_equal 1, result.remaining_count
      assert_empty result.routes_untracked
      assert_empty result.routes_stale
    end
  end

  test "reviewed non-production actions no longer count as pending" do
    with_inventory do |inventory, root|
      route = build_route(
        root,
        controller: "action_mailbox/ingresses/relay/inbound_emails",
        action: "create"
      )
      route = route.with(owner: "mounted_engine", disposition: "review")
      inventory.update_with_routes_for_test!([route])
      root.join("docs/authorization_migration/exceptions.txt").write(
        "action_mailbox/ingresses/relay/inbound_emails#create | reviewed | Engine authenticates ingress | Rob | 2026-07-24\n"
      )

      result = inventory.status

      assert_equal 0, result.reviews_pending
      assert_equal 0, result.exit_status
    end
  end

  test "partially migrated actions are listed before untouched actions" do
    with_inventory do |inventory, root|
      create_controller(root, "api/v1/polls")
      routes = [
        build_route(root, controller: "api/v1/polls", action: "index"),
        build_route(root, controller: "api/v1/polls", action: "show", path: "/api/v1/polls/:id")
      ]
      inventory.update_with_routes_for_test!(routes)
      tracker_path = root.join("docs/authorization_migration/controllers/api_v1_polls_controller.txt")
      tracker = tracker_path.read.sub(
        /(\[action show\].*?status = )inventoried/m,
        "\\1characterized"
      )
      tracker_path.write(tracker)

      result = inventory.status

      assert_equal "api/v1/polls#show", result.next_actions.first.first
    end
  end

  private

  def with_inventory
    Dir.mktmpdir do |directory|
      root = Pathname(directory)
      inventory = AuthorizationMigration::Inventory.new(root:)
      inventory.define_singleton_method(:update_with_routes_for_test!) do |routes|
        FileUtils.mkdir_p(send(:tracker_directory))
        FileUtils.mkdir_p(send(:controller_directory))
        send(:write_routes, routes)
        send(:write_missing_action_trackers, routes)
        send(:write_supporting_files)
        result = check(routes:)
        send(:write_coverage, result)
        result
      end
      yield inventory, root
    end
  end

  def create_controller(root, controller)
    path = root.join("app/controllers/#{controller}_controller.rb")
    FileUtils.mkdir_p(path.dirname)
    path.write("class PlaceholderController; end\n")
  end

  def build_route(root, controller:, action:, verb: "GET", path: "/api/v1/polls")
    owner = root.join("app/controllers/#{controller}_controller.rb").exist? ?
      "first_party_production" :
      "unknown"
    AuthorizationMigration::Inventory::Route.new(
      route_key: [verb, path, controller, action].join("|"),
      verb: verb,
      path: path,
      controller: controller,
      action: action,
      environment: "production",
      owner: owner,
      disposition: owner == "first_party_production" ? "migrate" : "review"
    )
  end
end
