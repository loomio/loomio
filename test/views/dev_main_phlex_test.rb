require "test_helper"

class DevMainPhlexTest < ActiveSupport::TestCase
  def render_phlex(component)
    ApplicationController.renderer.render(component, layout: false)
  end

  test "scenario index renders routes and poll formats" do
    output = render_phlex(Views::Dev::Main::Index.new(routes: %w[test_zebra test_alpha]))

    assert_operator output.index("test_alpha"), :<, output.index("test_zebra")
    assert_includes output, "/dev/polls/test_poll_scenario?poll_type=proposal"
    assert_includes output, "format=markdown"
  end

  test "last email renders the empty state" do
    output = render_phlex(Views::Dev::Main::LastEmail.new(
      email: nil,
      scenario: nil,
      action_name: "last_email"
    ))

    assert_includes output, "no emails sent"
  end

  test "last email renders headers and HTML body" do
    email = Mail.new(
      to: "recipient@example.com",
      from: "sender@example.com",
      subject: "Rendered email",
      body: "<p>Email body</p>"
    )

    output = render_phlex(Views::Dev::Main::LastEmail.new(
      email: email,
      scenario: nil,
      action_name: "last_email"
    ))

    assert_includes output, "recipient@example.com"
    assert_includes output, "Rendered email"
    assert_includes output, "<p>Email body</p>"
  end
end
