require 'test_helper'

class Api::V1::AttachmentsControllerTest < ActionController::TestCase
  test "index finds files attached to discussions" do
    user = users(:normal_user)
    group = groups(:test_group)
    discussion = create_discussion(author: user, group: group)
    
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'strongbad.png')),
      filename: 'strongbad.png',
      content_type: 'image/jpeg'
    )
    discussion.files.attach(blob)
    discussion.save!
    
    sign_in user
    get :index, params: { q: "strongbad", group_id: discussion.group_id }
    assert_response :success
    
    json = JSON.parse(response.body)
    assert_equal 'strongbad.png', json['attachments'][0]['filename']
  end

  test "destroy allowed if admin" do
    user = users(:normal_user)
    group = groups(:test_group)
    discussion = create_discussion(author: user, group: group)
    group.add_admin! user
    
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'strongbad.png')),
      filename: 'strongbad.png',
      content_type: 'image/jpeg'
    )
    discussion.files.attach(blob)
    discussion.files.last.update_attribute(:group_id, discussion.group_id)
    attachment = discussion.files.last
    
    sign_in user
    delete :destroy, params: { id: attachment.id }
    assert_response :success
  end

  test "destroy disallowed if not admin" do
    # Create a discussion as discussion_author
    author = users(:discussion_author)
    group = groups(:test_group)
    discussion = create_discussion(author: author, group: group)
    
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'strongbad.png')),
      filename: 'strongbad.png',
      content_type: 'image/jpeg'
    )
    discussion.files.attach(blob)
    discussion.files.last.update_attribute(:group_id, discussion.group_id)
    attachment = discussion.files.last
    
    # Try to delete as a non-admin user (another_user has admin: false in fixtures)
    non_admin = users(:another_user)
    sign_in non_admin
    delete :destroy, params: { id: attachment.id }
    assert_response :forbidden
  end
end
