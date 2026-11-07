require 'test_helper'
require 'rake'

class OrphanTopicsTaskTest < ActiveSupport::TestCase
  setup do
    @destroy_before = ENV['DESTROY_ORPHAN_TOPICS']
    ENV.delete('DESTROY_ORPHAN_TOPICS')
    Rake::Task.define_task(:environment) unless Rake::Task.task_defined?(:environment)
    load Rails.root.join('lib/tasks/loomio.rake') unless Rake::Task.task_defined?('loomio:orphan_topics')
    @task = Rake::Task['loomio:orphan_topics']
    @task.reenable
    @topic = discussions(:discussion).topic
    Discussion.where(id: @topic.topicable_id).delete_all
  end

  teardown do
    @destroy_before.nil? ? ENV.delete('DESTROY_ORPHAN_TOPICS') : ENV['DESTROY_ORPHAN_TOPICS'] = @destroy_before
    @task.reenable
  end

  test 'reports topics without their thread and leaves them in place' do
    output, = capture_io { @task.invoke }

    assert_match(/^#{@topic.id}\tDiscussion\t/, output)
    assert Topic.exists?(@topic.id)
  end

  test 'destroys them when asked' do
    ENV['DESTROY_ORPHAN_TOPICS'] = '1'

    output, = capture_io { @task.invoke }

    assert_match(/Destroyed \d+/, output)
    assert_not Topic.exists?(@topic.id)
    assert_empty Topic.where.not(id: Topic.with_topicable.select(:id))
  end
end
