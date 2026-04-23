require 'test_helper'

class LegacyVariationTranslatorTest < ActiveSupport::TestCase
  test "translates ImageMagick shrink-only geometry to resize_to_limit" do
    result = LegacyVariationTranslator.call(resize: "1200x1200>")
    assert_equal({resize_to_limit: [1200, 1200]}, result)
  end

  test "translates geometry with no modifier to resize_to_limit" do
    result = LegacyVariationTranslator.call(resize: "800x600")
    assert_equal({resize_to_limit: [800, 600]}, result)
  end

  test "translates fill geometry (^) to resize_to_fill" do
    result = LegacyVariationTranslator.call(resize: "400x400^")
    assert_equal({resize_to_fill: [400, 400]}, result)
  end

  test "translates force-exact geometry (!) to resize_to_fit" do
    result = LegacyVariationTranslator.call(resize: "512x512!")
    assert_equal({resize_to_fit: [512, 512]}, result)
  end

  test "preserves sibling transformations" do
    result = LegacyVariationTranslator.call(resize: "1280x1280>", saver: {quality: 85, strip: true})
    assert_equal({resize_to_limit: [1280, 1280], saver: {quality: 85, strip: true}}, result)
  end

  test "lifts top-level quality into saver and casts to integer" do
    result = LegacyVariationTranslator.call(resize: "1200x1200>", quality: "85")
    assert_equal({resize_to_limit: [1200, 1200], saver: {quality: 85}}, result)
  end

  test "lifts top-level strip into saver and casts to boolean" do
    result = LegacyVariationTranslator.call(resize: "800x800>", strip: "true")
    assert_equal({resize_to_limit: [800, 800], saver: {strip: true}}, result)
  end

  test "merges lifted saver keys with existing saver hash" do
    result = LegacyVariationTranslator.call(resize_to_limit: [600, 600], saver: {strip: true}, quality: "90")
    assert_equal({resize_to_limit: [600, 600], saver: {strip: true, quality: 90}}, result)
  end

  test "passes modern transformations through unchanged" do
    input = {resize_to_limit: [512, 512], saver: {quality: 80}}
    assert_equal input, LegacyVariationTranslator.call(input)
  end

  test "leaves non-geometry resize values alone" do
    input = {resize: 0.5}
    assert_equal input, LegacyVariationTranslator.call(input)
  end

  test "handles string keys" do
    result = LegacyVariationTranslator.call("resize" => "100x100>")
    assert_equal({resize_to_limit: [100, 100]}, result)
  end

  test "returns non-hash input unchanged" do
    assert_equal "not a hash", LegacyVariationTranslator.call("not a hash")
    assert_nil LegacyVariationTranslator.call(nil)
  end
end
