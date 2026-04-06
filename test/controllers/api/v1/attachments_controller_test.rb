require 'test_helper'

class Api::V1::AttachmentsControllerTest < ActionController::TestCase
  test "index finds files attached to discussions" do
    user = users(:user)
    discussion = discussions(:discussion)

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
    admin = users(:admin)
    discussion = discussions(:discussion)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'strongbad.png')),
      filename: 'strongbad.png',
      content_type: 'image/jpeg'
    )
    discussion.files.attach(blob)
    discussion.files.last.update_attribute(:group_id, discussion.group_id)
    attachment = discussion.files.last

    sign_in admin
    delete :destroy, params: { id: attachment.id }
    assert_response :success
  end

  test "destroy disallowed if not admin" do
    discussion = discussions(:discussion)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'strongbad.png')),
      filename: 'strongbad.png',
      content_type: 'image/jpeg'
    )
    discussion.files.attach(blob)
    discussion.files.last.update_attribute(:group_id, discussion.group_id)
    attachment = discussion.files.last

    sign_in users(:user)
    delete :destroy, params: { id: attachment.id }
    assert_response :forbidden
  end
end
