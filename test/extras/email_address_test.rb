require 'test_helper'

class EmailAddressTest < Minitest::Test
  def test_normalization_preserves_distinct_dotted_and_plus_tagged_mailboxes
    address = EmailAddress.normalize(' First.Last+Work@Gmail.com ')
    assert_equal 'first.last+work@gmail.com', address
    refute_equal EmailAddress.normalize('firstlast@gmail.com'), address
    refute_equal EmailAddress.normalize('first.last@gmail.com'), address
  end

  def test_suppression_digest_keeps_the_existing_canonical_identity
    address = ' Person+Events@Example.COM '
    assert_equal Digest::SHA256.hexdigest('person+events@example.com'), EmailSuppression.address_digest(address)
    assert_equal '', EmailAddress.normalize(nil)
    assert_equal '', EmailAddress.normalize('  ')
  end
end
