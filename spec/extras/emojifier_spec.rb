require 'rails_helper'

xdescribe Emojifier do
  let(:normal) { "Hi I'm some text" }
  let(:html) { "<a href=\"loomio.org\">Click me!</a><br/>" }
  let(:weird) { "&%<\n\r\"\u2028\u2029!+=" }
  let(:with_shortcode) { ":sad_noodle:" }
  let(:with_emoji) { ":heart:" }

  before do
    expect(Raven).to_not receive :capture_exception
  end

  it 'renders text normally' do
    expect(emojify(normal)).to eq normal
  end

  it 'renders absolute urls for emojis' do
    expect(emojify(with_emoji)).to include 'http://'
  end

  it 'can handle html' do
    expect(emojify(html)).to eq html
  end

  it 'can handle quotes and other odd characters' do
    expect(emojify(weird)).to eq weird
  end

  it 'emojifies shortcodes with corresponding emoji' do
    expect(emojify(with_emoji)).to match /img/
  end

  it 'does not emojify non-shortcodes' do
    expect(emojify(with_shortcode)).to eq with_shortcode
  end

  it 'can get just the image source for an emoji' do
    expect(emojify_src(with_emoji)).to match /img\/emojis\//
  end

  it 'returns nil if emoji shortcode not found' do
    expect(emojify_src(normal)).to be_nil
  end

  def emojify(text)
    Emojifier.emojify!(text)
  end

  def emojify_src(text)
    Emojifier.emojify_src!(text)
  end

end
