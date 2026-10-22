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

  test "translation exports omit defaults and retain custom text tags and option prompts" do
    defaults = AppConfig.poll_types.fetch('proposal').fetch('defaults')
    fields = %w[title title_placeholder process_name process_subtitle process_introduction details reason_prompt outcome_statement]
    template = poll_template(defaults.slice(*fields).merge(
      'process_name' => 'Board vote', 'process_subtitle' => 'Member review',
      'tags' => ['Board Members'],
      'poll_options' => [{'name' => 'Support this', 'meaning' => 'Agree', 'prompt' => 'Your reason'}]
    ))

    exported = template.dump_i18n.fetch('board_vote')

    assert_not exported.key?('title')
    assert_equal 'Member review', exported.fetch('process_subtitle')
    assert_equal 'Board Members', exported.fetch('board_members')
    assert_equal 'Support this', exported.fetch('support_this')
    assert_equal 'Agree', exported.fetch('support_this_meaning')
    assert_equal 'Your reason', exported.fetch('support_this_prompt')
  end
end
