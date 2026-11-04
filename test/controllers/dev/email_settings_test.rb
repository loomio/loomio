require 'test_helper'

class Dev::EmailSettingsTest < ActionController::TestCase
  tests Dev::NightwatchController

  test "thread email settings preview reuses the sample group" do
    recipient = User.create!(name: 'Patrick Swayze', email: 'patrick@example.com', username: 'patrickswayze', email_verified: true)
    group = Group.create!(name: 'Dirty Dancing Shoes', handle: 'shoes', group_privacy: 'closed', creator: recipient)
    group.add_member!(recipient)

    get :view_thread_email_settings

    assert_response :redirect
    redirect_query = Rack::Utils.parse_nested_query(URI.parse(response.location).query)
    assert redirect_query.key?('topic_id'), "Redirect query keys: #{redirect_query.keys.inspect}"
    discussion = Discussion.joins(:topic).find_by!(title: 'What star sign are you?', topics: {group_id: group.id})
    assert_redirected_to email_actions_unsubscribe_path(topic_id: discussion.topic.id, unsubscribe_token: recipient.unsubscribe_token)

    get :view_thread_email_settings

    assert_redirected_to email_actions_unsubscribe_path(topic_id: discussion.topic.id, unsubscribe_token: recipient.unsubscribe_token)
    assert_equal 1, Discussion.joins(:topic).where(title: discussion.title, topics: {group_id: group.id}).count
  end
end
