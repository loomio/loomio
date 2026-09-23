require "test_helper"

class PollTemplateServiceTest < ActiveSupport::TestCase
  test "built-in templates use their intended reason requirement" do
    templates = PollTemplateService.default_templates + PollTemplateService.example_templates
    reason_requirements = {
      "consent" => "required_for_disagree_or_block",
      "consensus" => "required_for_block",
      "question" => "required"
    }

    templates.each do |template|
      assert_equal reason_requirements.fetch(template.key, "optional"), template.stance_reason_required, template.key
    end
  end
end
