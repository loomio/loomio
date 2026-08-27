require 'test_helper'

class MarkdownServiceTest < ActiveSupport::TestCase
  test "rich text media attributes and task dates cannot become markup" do
    payload = "'>&lt;img src=x onerror=alert(1)&gt;"
    html = <<~HTML
      <video src="https://video.test/#{payload}" poster="https://image.test/#{payload}"></video>
      <audio src="https://audio.test/#{payload}"></audio>
      <iframe src="https://invalid.test/#{payload}"></iframe>
      <li data-type="taskItem" data-due-on="2026-08-27#{payload}">Task</li>
    HTML

    VideoInfo.stub(:new, ->(_) { raise ArgumentError }) do
      rendered = MarkdownService.render_rich_text(html, 'html')
      fragment = Nokogiri::HTML5::DocumentFragment.parse(rendered)

      assert_empty fragment.css('img[onerror]')
      assert_equal 1, fragment.css('img').length
      assert_equal 3, fragment.css('a').length
      assert_includes fragment.text, '<img src=x onerror=alert(1)>'
      assert_includes fragment.at_css('.mailer-tag').text, '<img src=x onerror=alert(1)>'
    end
  end

  test "rich text media keeps links thumbnails and labels" do
    video_info = Struct.new(:url, :thumbnail).new(
      'https://video.test/watch?v=1&mode=full',
      'https://video.test/thumbnail.jpg?size=large&crop=center'
    )
    html = <<~HTML
      <video src="https://media.test/video.mp4?x=1&amp;y=2" poster="https://media.test/poster.jpg?x=1&amp;y=2"></video>
      <audio src="https://media.test/audio.mp3?x=1&amp;y=2"></audio>
      <iframe src="https://video.test/embed/1"></iframe>
    HTML

    VideoInfo.stub(:new, video_info) do
      fragment = Nokogiri::HTML5::DocumentFragment.parse(MarkdownService.render_rich_text(html, 'html'))
      links = fragment.css('a')

      assert_equal 'https://media.test/video.mp4?x=1&y=2', links[0]['href']
      assert_equal 'https://media.test/poster.jpg?x=1&y=2', links[0].at_css('img')['src']
      assert_includes links[0].text, I18n.t('record_modal.watch_video')
      assert_equal 'https://media.test/audio.mp3?x=1&y=2', links[1]['href']
      assert_includes links[1].text, I18n.t('record_modal.listen_to_audio')
      assert_equal video_info.url, links[2]['href']
      assert_equal video_info.thumbnail, links[2].at_css('img')['src']
    end
  end
end
