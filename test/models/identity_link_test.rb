require 'test_helper'

class IdentityLinkTest < ActiveSupport::TestCase
  setup do
    @identity = Identity.create!(identity_type: 'oauth', uid: 'link-test', email: users(:member_loud).email)
  end

  test 'only active accounts can link a pending identity' do
    assert_not @identity.link_to_user!(users(:inactive_member_loud))
    assert_nil @identity.reload.user_id
    assert @identity.link_to_user!(users(:member_loud))
    assert_equal users(:member_loud).id, @identity.reload.user_id
  end

  test 'competing consumers cannot reassign a linked identity using stale records' do
    first = Identity.find(@identity.id)
    second = Identity.find(@identity.id)
    assert first.link_to_user!(users(:member_loud))
    assert_not second.link_to_user!(users(:alien_loud))
    assert_equal users(:member_loud).id, @identity.reload.user_id
  end

  test 'failed linking leaves the identity pending for retry' do
    @identity.stub(:update!, ->(**) { raise ActiveRecord::RecordInvalid, @identity }) do
      assert_raises(ActiveRecord::RecordInvalid) { @identity.link_to_user!(users(:member_loud)) }
    end
    assert_nil @identity.reload.user_id
    assert @identity.link_to_user!(users(:member_loud))
  end
end
