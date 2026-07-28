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

  test "index includes anonymous stance attachments while results are hidden" do
    admin = users(:admin)
    user = users(:user)
    voter = users(:member)
    group = groups(:group)
    group.add_member!(voter)
    poll = PollService.create(params: {
      title: "Anonymous attachment poll",
      poll_type: "proposal",
      group_id: group.id,
      anonymous: true,
      hide_results: "until_closed",
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 1.day.from_now
    }, actor: admin)
    stance = poll.stances.latest.find_by!(participant_id: voter.id)
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'strongbad.png')),
      filename: 'anonymous-voter-secret.png',
      content_type: 'image/png'
    )
    stance.files.attach(blob)

    sign_in user
    get :index, params: {group_id: group.id, q: "anonymous-voter-secret"}

    assert_response :success
    assert_equal 'anonymous-voter-secret.png', JSON.parse(response.body).fetch('attachments').first['filename']
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
