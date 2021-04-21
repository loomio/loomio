module LinkPreviewService
  def self.fetch(url)
    # require logged in user
    # add rate limit of 100 per hour per user
    response = HTTParty.get(url)
    return nil if response.code != 200
    doc = Nokogiri::HTML::Document.parse(response.body)

    title = [doc.css('meta[property="og:title"]').attr('content').to_s,
             doc.css('title').first&.text,
             doc.css('h1').first&.text].reject(&:blank?).first

    description = [doc.css('meta[property="og:description"]').attr('content').to_s,
                   doc.css('meta[name="description"]').attr('content').to_s].reject(&:blank?).first

    image = [doc.css('meta[property="og:image"]').attr('content').to_s,
             doc.css('link[rel="image_src"]').attr('href').to_s].reject(&:blank?).first

    url = [doc.css('meta[property="og:url"]').attr('content').to_s,
          doc.css('link[rel="canonical"]').attr('href').to_s,
          url].reject(&:blank?).first


    {title: title, description: description, image: image, url: url, hostname: URI(url).host}
  end

  def self.fetch_urls(urls)
    previews = []
    threads = []
    urls.each do |u|
      # spawn a new thread for each url
      threads << Thread.new do
        previews.push fetch(u)
      end
    end
    threads.each { |t| t.join }
    previews.compact
  end
end
