require 'test_helper'
require 'digest'
require 'mini_magick'

class EmailVoteAssetsTest < ActiveSupport::TestCase
  ASSET_DIR = Rails.root.join('app/assets/images/poll_mailer')
  SIGNAL_COLORS = {
    'agree' => [[34, 184, 102], [13, 122, 60]],
    'abstain' => [[245, 196, 1], [168, 121, 0]],
    'disagree' => [[240, 82, 82], [170, 32, 32]],
    'block' => [[89, 89, 89], [17, 17, 17]],
  }.freeze

  test "semantic vote images use the current brand colors at 128px" do
    SIGNAL_COLORS.each do |name, colors|
      image = MiniMagick::Image.open(asset_path(name))
      pixels = image.get_pixels.flatten(1)

      assert_equal [128, 128], [image.width, image.height], name
      colors.each { |color| assert_includes pixels, color, "#{name} does not contain #{color}" }
    end
  end

  test "semantic aliases use the canonical images" do
    assert_same_image 'agree', 'consent'
    assert_same_image 'agree', 'yes'
    assert_same_image 'disagree', 'objection'
    assert_same_image 'disagree', 'no'
  end

  private

  def asset_path(name)
    ASSET_DIR.join("vote-button-#{name}.png")
  end

  def assert_same_image(canonical, alias_name)
    assert_equal Digest::SHA256.file(asset_path(canonical)).hexdigest,
                 Digest::SHA256.file(asset_path(alias_name)).hexdigest
  end
end
