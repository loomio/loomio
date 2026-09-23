require 'test_helper'

class PieChartControllerTest < ActionController::TestCase
  test "renders the pie chart with a transparent background" do
    get :show, params: { scores: '1', colors: 'e25555' }

    assert_response :success
    assert_equal 'image/png', response.media_type

    image = MiniMagick::Image.read(response.body, '.png')
    pixels = image.get_pixels('RGBA')
    assert_equal [ 0, 0, 0, 0 ], pixels.first.first
    assert_equal [ 226, 85, 85, 255 ], pixels[256][256]
  end
end
