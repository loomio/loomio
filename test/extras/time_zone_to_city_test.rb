require 'test_helper'

class TimeZoneToCityTest < ActiveSupport::TestCase
  test "converts common IANA timezone to city name" do
    assert_equal "Auckland", TimeZoneToCity.convert("Pacific/Auckland")
  end

  test "converts obscure IANA timezone to city name" do
    assert_equal "Wellington", TimeZoneToCity.convert("Pacific/Tarawa")
  end
end
