require 'test_helper'

class PollTemplateTest < ActiveSupport::TestCase
  def poll_template(attrs = {})
    PollTemplate.new({
      group: groups(:group),
      author: users(:admin),
      process_name: "Board vote",
      process_subtitle: "subtitle",
      poll_type: "proposal",
      default_duration_in_days: 7,
      weighted_voting: true
    }.merge(attrs))
  end

  test "a proposal template can use weighted voting" do
    assert poll_template.valid?
  end

  test "templates reject weighted voting where polls do" do
    [{anonymous: true}, {poll_type: 'meeting'}, {poll_type: 'stv'}].each do |attrs|
      template = poll_template(attrs)
      refute template.valid?, attrs.inspect
      assert template.errors.added?(:weighted_voting, :invalid), attrs.inspect
    end
  end
end
