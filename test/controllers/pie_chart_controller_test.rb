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

  test "rejects invalid color parameters" do
    get :show, params: { scores: '1', colors: 'e25555"><script>alert(1)</script>' }

    assert_response :bad_request
  end

  test "rejects missing or excessive slices" do
    get :show, params: { scores: '', colors: 'e25555' }
    assert_response :bad_request

    get :show, params: { scores: Array.new(51, '1').join(','), colors: 'e25555' }
    assert_response :bad_request
  end
end
