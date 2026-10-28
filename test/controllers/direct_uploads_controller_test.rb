require 'test_helper'

class DirectUploadsControllerTest < ActionController::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @trial_user = User.create!(name: "trial#{hex}", email: "trial#{hex}@example.com", username: "trial#{hex}", email_verified: true)
    @paid_user  = User.create!(name: "paid#{hex}",  email: "paid#{hex}@example.com",  username: "paid#{hex}",  email_verified: true)

    @trial_group = Group.new(name: "trialg#{hex}", group_privacy: 'secret', handle: "trialg#{hex}")
    @trial_group.creator = @trial_user
    @trial_group.save!
    @trial_group.add_admin!(@trial_user)
    Subscription.for(@trial_group).update!(plan: 'trial')

    @paid_group = Group.new(name: "paidg#{hex}", group_privacy: 'secret', handle: "paidg#{hex}")
    @paid_group.creator = @paid_user
    @paid_group.save!
    @paid_group.add_admin!(@paid_user)
    Subscription.for(@paid_group).update!(plan: 'standard', state: 'active')
  end

  def blob_params(byte_size:)
    {
      blob: {
        filename: 'a.pdf',
        content_type: 'application/pdf',
        byte_size: byte_size,
        checksum: Digest::MD5.base64digest('x')
      }
    }
  end

  test "allows uploads within and at the trial limit with the editor download contract" do
    sign_in @trial_user
    [1.megabyte, DirectUploadsController::TRIAL_MAX_UPLOAD_BYTES].each do |byte_size|
      post :create, params: blob_params(byte_size: byte_size), format: :json
      assert_response :success
      payload = response.parsed_body
      blob = ActiveStorage::Blob.find(payload.fetch('id'))
      assert_equal blob.signed_id, payload.fetch('signed_id')
      assert_equal rails_blob_path(blob, only_path: true), payload.fetch('download_url')
      assert payload.fetch('direct_upload').fetch('url').present?
    end
  end

  test "rejects executable script and SVG content before creating a blob" do
    sign_in @trial_user
    %w[application/x-msdownload application/javascript image/svg+xml IMAGE/SVG+XML].each do |content_type|
      assert_no_difference 'ActiveStorage::Blob.count' do
        post :create, params: blob_params(byte_size: 1_024).deep_merge(blob: { content_type: content_type }), format: :json
      end
      assert_response :unprocessable_entity
      assert_equal 'This file type is not allowed', response.parsed_body.fetch('error')
    end
  end

  test "image uploads include a preview path while plain text uploads omit it" do
    sign_in @trial_user
    [['image/png', true], ['text/plain', false]].each do |content_type, preview|
      post :create, params: blob_params(byte_size: 1_024).deep_merge(blob: { content_type: content_type }), format: :json
      assert_response :success
      payload = response.parsed_body
      assert_equal preview, payload.key?('preview_url')
      assert_match(%r{\A/rails/active_storage/representations/}, payload.fetch('preview_url')) if preview
    end
  end

  test "rejects blank filename before creating a blob" do
    sign_in @trial_user
    assert_no_difference('ActiveStorage::Blob.count') do
      post :create, params: blob_params(byte_size: 1024).deep_merge(blob: { filename: ' ' }), format: :json
    end
    assert_response :unprocessable_entity
    assert_equal I18n.t('upload.filename_required'), JSON.parse(response.body).fetch('error')
  end

  test "rejects upload over trial limit for trial user" do
    sign_in @trial_user
    post :create, params: blob_params(byte_size: DirectUploadsController::TRIAL_MAX_UPLOAD_BYTES + 1), format: :json
    assert_response :unprocessable_entity
    assert_equal I18n.t(
      'upload.file_too_large',
      limit: ActiveSupport::NumberHelper.number_to_human_size(DirectUploadsController::TRIAL_MAX_UPLOAD_BYTES)
    ), JSON.parse(response.body).fetch('error')
  end

  test "allows paid user to upload above trial limit" do
    sign_in @paid_user
    refute @trial_user.is_paying?
    assert @paid_user.is_paying?
    post :create, params: blob_params(byte_size: DirectUploadsController::TRIAL_MAX_UPLOAD_BYTES + 1), format: :json
    assert_response :success
  end

  test "rejects upload over paid limit even for paid user" do
    sign_in @paid_user
    post :create, params: blob_params(byte_size: DirectUploadsController::PAID_MAX_UPLOAD_BYTES + 1), format: :json
    assert_response :unprocessable_entity
  end

  test "anonymous upload is rejected as unauthorized" do
    post :create, params: blob_params(byte_size: 1024), format: :json
    assert_response :unauthorized
  end
end
