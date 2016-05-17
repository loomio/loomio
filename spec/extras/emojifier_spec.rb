require 'rails_helper'

describe Emojifier do
  let(:normal) { "Hi I'm some text" }
  let(:html) { "<a href=\"loomio.org\">Click me!</a><br/>" }
  let(:weird) { "&%<\n\r\"\u2028\u2029!+=" }
  let(:with_shortcode) { ":sad_noodle:" }
  let(:with_emoji) { ":heart:" }

  before do
    expect(Airbrake).to_not receive :notify
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

  def emojify(text)
    Emojifier.emojify!(text)
  end

end
