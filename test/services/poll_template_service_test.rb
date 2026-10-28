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

  test "group discovery retains stored templates and applies built-in visibility positions and example state" do
    group = groups(:group)
    group.hidden_poll_templates = ['consent']
    group.poll_template_positions['consent'] = 42
    stored = PollTemplate.create!(group: group, author: users(:admin), poll_type: 'proposal',
      process_name: 'Stored process', process_subtitle: 'Group process', default_duration_in_days: 3)

    templates = PollTemplateService.group_templates(group: group)

    assert_includes templates.map(&:id).compact, stored.id
    consent = templates.find { |template| template.key == 'consent' }
    assert_equal group.id, consent.group_id
    assert_equal 42, consent.position
    assert_predicate consent, :hidden?
    assert_not templates.find { |template| template.key == 'consensus' }.hidden?
    example = templates.find { |template| template.key == 'practice_proposal' }
    assert_equal group.id, example.group_id
    assert_predicate example, :example?
    assert_not templates.any? { |template| template.key == 'question' }
  end

  test "built-in templates translate option text and tag arrays while retaining option settings" do
    I18n.with_locale(:en) do
      templates = PollTemplateService.example_templates
      practice = templates.find { |template| template.key == 'practice_proposal' }
      assert_equal I18n.t('poll_templates.practice_proposal.process_name'), practice.process_name
      assert_equal I18n.t('poll_proposal_options.agree'), practice.poll_options.first.fetch('name')
      assert_equal I18n.t('poll_templates.practice_proposal.agree_meaning'), practice.poll_options.first.fetch('meaning')
      assert_equal I18n.t('poll_templates.practice_proposal.agree_prompt'), practice.poll_options.first.fetch('prompt')
      assert_equal 'agree', practice.poll_options.first.fetch('icon')
      question = templates.find { |template| template.key == 'question' }
      assert_equal [I18n.t('poll_common.question_round')], question.tags
    end
  end

  test "saving a customized built-in template creates an authored copy without the built-in key" do
    group = groups(:group)
    group.hidden_poll_templates = []
    template = PollTemplateService.default_templates.find { |item| item.key == 'consent' }
    template.group = group
    template.process_name = 'Our consent process'

    result = PollTemplateService.create(poll_template: template, actor: users(:admin))

    assert_same template, result
    assert_predicate result, :persisted?
    assert_nil result.reload.key
    assert_equal users(:admin), result.author
  end

  test "invalid creation and update return the template without saving changes" do
    template = PollTemplate.new(group: groups(:group), poll_type: 'proposal',
      process_name: '', process_subtitle: 'Invalid process', default_duration_in_days: 3)
    assert_no_difference 'PollTemplate.count' do
      assert_same template, PollTemplateService.create(poll_template: template, actor: users(:admin))
    end
    assert_predicate template, :invalid?
    template.process_name = 'Saved process'
    template.save!

    result = PollTemplateService.update(poll_template: template, actor: users(:admin), params: {process_name: ''})

    assert_same template, result
    assert_predicate result, :invalid?
    assert_equal 'Saved process', template.reload.process_name
  end
end
