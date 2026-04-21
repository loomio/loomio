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

  test "allows upload within trial limit" do
    sign_in @trial_user
    post :create, params: blob_params(byte_size: 1.megabyte), format: :json
    assert_response :success
  end

  test "rejects upload over trial limit for trial user" do
    sign_in @trial_user
    post :create, params: blob_params(byte_size: DirectUploadsController::TRIAL_MAX_UPLOAD_BYTES + 1), format: :json
    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body).fetch('error'), 'too large'
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

  test "anonymous upload is treated as trial tier" do
    post :create, params: blob_params(byte_size: DirectUploadsController::TRIAL_MAX_UPLOAD_BYTES + 1), format: :json
    assert_response :unprocessable_entity
  end
end
