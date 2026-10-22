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
    assert_equal [blob.id], discussion.reload.attachments.pluck('id')

    sign_in admin
    assert_enqueued_with(job: ActiveStorage::PurgeJob, args: [blob]) do
      delete :destroy, params: { id: attachment.id }
    end
    assert_response :success
    refute ActiveStorage::Attachment.exists?(attachment.id)
    assert_empty discussion.reload.attachments
    serialized = response.parsed_body.fetch('discussions').find { |record| record['id'] == discussion.id }
    assert_empty serialized.fetch('attachments')
  end

  test "index pages matching group files while keeping the full matching total" do
    discussion = topics(:discussion_topic).topicable
    blobs = 3.times.map do |index|
      File.open(Rails.root.join('spec', 'fixtures', 'images', 'strongbad.png')) do |file|
        ActiveStorage::Blob.create_and_upload!(io: file, filename: "paged-file-#{index}.png", content_type: 'image/png')
      end
    end
    discussion.files.attach(blobs)
    discussion.save!
    attachments = discussion.files.order(id: :desc).to_a
    sign_in users(:member_normal)

    get :index, params: { q: 'paged-file', group_id: discussion.group_id, per: 1, from: 1 }

    assert_response :success
    assert_equal [attachments[1].id], response.parsed_body.fetch('attachments').pluck('id')
    assert_equal 3, response.parsed_body.fetch('meta').fetch('total')
  end

  test "group file lists deny topic guests revoked members outsiders and instance administrators" do
    %i[guest_normal former_member_loud alien server_admin].each do |role|
      sign_in users(role)

      get :index, params: { q: 'strongbad', group_id: groups(:group).id }

      assert_response :not_found, role.to_s
      refute response.parsed_body.key?('attachments'), role.to_s
    end
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
