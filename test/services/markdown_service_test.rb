require 'test_helper'

class MarkdownServiceTest < ActiveSupport::TestCase
  test "client mode conversion produces Markdown compatible with server rendering" do
    JSON.parse(file_fixture("markdown_conversion.json").read).each do |fixture|
      fragment = Nokogiri::HTML5::DocumentFragment.parse(MarkdownService.render_html(fixture.fetch("markdown")))

      fixture.fetch("server").each do |expected|
        nodes = fragment.css(expected.fetch("selector"))
        assert_equal Array(expected["texts"] || expected.fetch("text")), nodes.map { |node| node.text.strip }, fixture.fetch("name")
        assert_equal expected["href"], nodes.first["href"], fixture.fetch("name") if expected.key?("href")
      end
    end
  end

  test "markdown replaces unsafe link and image URLs" do
    markdown = <<~MARKDOWN
      <script>alert(1)</script>
      <img src="https://example.test/raw.png" onerror="alert(1)">

      [javascript](javascript:alert(1))
      [mixed case](JaVaScRiPt:alert(1))
      [encoded colon](javascript&#58;alert(1))
      [encoded letter](java&#x73;cript:alert(1))
      [encoded whitespace](java&Tab;script&colon;alert(1))
      [data](data:text/html,<script>alert(1)</script>)
      <javascript:alert(1)>
      ![image](javascript:alert(1))
    MARKDOWN

    fragment = Nokogiri::HTML5::DocumentFragment.parse(MarkdownService.render_html(markdown))

    assert_equal ['#'] * 7, fragment.css('a').map { |link| link['href'] }
    assert_equal ['#'], fragment.css('img').map { |image| image['src'] }
    assert_empty fragment.css('script, [onerror]')
  end

  test "markdown preserves safe link and image URLs" do
    markdown = <<~MARKDOWN
      [https](https://example.test/path)
      [mailto](mailto:person@example.test)
      [telephone](tel:+123456789)
      [ftp](ftp://example.test/file)
      [root relative](/path?q=https://example.test)
      [protocol relative](//example.test/path)
      [fragment](#section)
      [relative](../image.png)
      <https://example.test/autolink>
      ![image](images/example.png)
    MARKDOWN

    fragment = Nokogiri::HTML5::DocumentFragment.parse(MarkdownService.render_html(markdown))

    assert_equal [
      'https://example.test/path',
      'mailto:person@example.test',
      'tel:+123456789',
      'ftp://example.test/file',
      '/path?q=https://example.test',
      '//example.test/path',
      '#section',
      '../image.png',
      'https://example.test/autolink'
    ], fragment.css('a').map { |link| link['href'] }
    assert_equal ['images/example.png'], fragment.css('img').map { |image| image['src'] }
  end

  test "rich text media attributes and task dates cannot become markup" do
    payload = "'>&lt;img src=x onerror=alert(1)&gt;"
    html = <<~HTML
      <video src="https://video.test/#{payload}" poster="https://image.test/#{payload}"></video>
      <audio src="https://audio.test/#{payload}"></audio>
      <iframe src="https://invalid.test/#{payload}"></iframe>
      <li data-type="taskItem" data-due-on="2026-08-27#{payload}">Task</li>
    HTML

    rendered = MarkdownService.render_rich_text(html, 'html')
    fragment = Nokogiri::HTML5::DocumentFragment.parse(rendered)

    assert_empty fragment.css('img[onerror]')
    assert_equal 1, fragment.css('img').length
    assert_equal 3, fragment.css('a').length
    assert_includes fragment.text, '<img src=x onerror=alert(1)>'
    assert_includes fragment.at_css('.email-tag').text, '<img src=x onerror=alert(1)>'
  end

  test "rich text media keeps links thumbnails and labels" do
    html = <<~HTML
      <video src="https://media.test/video.mp4?x=1&amp;y=2" poster="https://media.test/poster.jpg?x=1&amp;y=2"></video>
      <audio src="https://media.test/audio.mp3?x=1&amp;y=2"></audio>
      <iframe src="https://www.youtube.com/embed/Zlzuqsunpxc"></iframe>
    HTML

    fragment = Nokogiri::HTML5::DocumentFragment.parse(MarkdownService.render_rich_text(html, 'html'))
    links = fragment.css('a')

    assert_equal 'https://media.test/video.mp4?x=1&y=2', links[0]['href']
    assert_equal 'https://media.test/poster.jpg?x=1&y=2', links[0].at_css('img')['src']
    assert_includes links[0].text, I18n.t('record_modal.watch_video')
    assert_equal 'https://media.test/audio.mp3?x=1&y=2', links[1]['href']
    assert_includes links[1].text, I18n.t('record_modal.listen_to_audio')
    assert_equal 'https://www.youtube.com/watch?v=Zlzuqsunpxc', links[2]['href']
    assert_equal 'https://i.ytimg.com/vi/Zlzuqsunpxc/hqdefault.jpg', links[2].at_css('img')['src']
    assert_equal I18n.t('record_modal.watch_video'), links[2].at_css('img')['alt']
    assert_not_requested :any, /youtube\.com|ytimg\.com/
  end

  test "YouTube video URL forms render the same thumbnail without network requests" do
    urls = [
      'https://www.youtube.com/embed/Zlzuqsunpxc?start=30',
      'https://www.youtube-nocookie.com/embed/Zlzuqsunpxc',
      'https://youtu.be/Zlzuqsunpxc?t=30',
      'https://www.youtube.com/watch?v=Zlzuqsunpxc&feature=shared',
      'https://m.youtube.com/watch?v=Zlzuqsunpxc',
      'https://www.youtube.com/shorts/Zlzuqsunpxc',
      'https://www.youtube.com/live/Zlzuqsunpxc',
      '//www.youtube.com/embed/Zlzuqsunpxc'
    ]
    urls.each do |url|
      fragment = Nokogiri::HTML5.fragment(MarkdownService.replace_iframes(%(<iframe src="#{CGI.escapeHTML(url)}"></iframe>)))
      assert_empty fragment.css('iframe')
      assert_equal 'https://www.youtube.com/watch?v=Zlzuqsunpxc', fragment.at_css('a')['href'], url
      assert_equal 'https://i.ytimg.com/vi/Zlzuqsunpxc/hqdefault.jpg', fragment.at_css('img')['src'], url
    end
    assert_not_requested :any, /youtube|youtu\.be|ytimg/
  end

  test "other providers and malformed YouTube URLs retain plain links" do
    urls = [
      'https://player.vimeo.com/video/12345',
      'https://www.loom.com/embed/12345',
      'https://youtube.com.example.test/embed/Zlzuqsunpxc',
      'https://www.youtube.com@evil.example.test/embed/Zlzuqsunpxc',
      'https://www.youtube.com/embed/invalid',
      'https://www.youtube.com/playlist?list=Zlzuqsunpxc',
      'https://www.youtube.com/watch?other=Zlzuqsunpxc',
      'not a valid URL'
    ]
    urls.each do |url|
      fragment = Nokogiri::HTML5.fragment(MarkdownService.replace_iframes(%(<iframe src="#{CGI.escapeHTML(url)}"></iframe>)))
      assert_empty fragment.css('img, iframe')
      assert_equal url, fragment.at_css('a')['href']
      assert_equal url, fragment.at_css('a').text
    end
    assert_not_requested :any, /vimeo|loom\.com|youtube|example\.test/
  end
end
