require "test_helper"

class DemoServiceTest < ActiveSupport::TestCase
  test "taking a demo provisions the code-backed mobile template" do
    actor = users(:user)
    group = groups(:group)
    captured = nil
    provision = lambda do |**args|
      captured = args
      DemoGroupTemplateService::Result.new(group: group, discussions: {}, polls: {}, notifications: [])
    end

    DemoGroupTemplateService.stub(:create!, provision) do
      assert_equal group, DemoService.take_demo(actor)
    end

    assert_equal({ template_key: "mobile", user: actor }, captured)
  end
end
