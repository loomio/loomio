module LinkPreviewService
  def self.fetch(url)
    # require logged in user
    # add rate limit of 100 per hour per user
    response = HTTParty.get(url)
    return nil if response.code != 200
    doc = Nokogiri::HTML::Document.parse(response.body)

    title = [doc.css('meta[property="og:title"]').attr('content')&.text,
             doc.css('title').first&.text,
             doc.css('h1').first&.text].reject(&:blank?).first

    bad_titles = [
      'Google Docs: Sign-in'
    ]

    return nil if title.blank?
    return nil if bad_titles.any? {|bt| bt.match?(title) }

    description = [doc.css('meta[property="og:description"]').attr('content')&.text,
                   doc.css('meta[name="description"]').attr('content')&.text].reject(&:blank?).first

    image = [doc.css('meta[property="og:image"]').attr('content')&.text,
             doc.css('meta[name="og:image"]').attr('content')&.text,
             doc.css('img[itemprop="image"]').attr('src')&.text,
             doc.css('link[rel="image_src"]').attr('href')&.text].reject(&:blank?).first

    {title: title,
     description: description,
     image: image,
     url: url,
     fit: 'contain',
     align: 'center',
     hostname: URI(url).host}
  end

  def self.fetch_urls(urls)
    previews = []
    threads = []
    urls.reject {|u| BlockedDomain.where(name: URI(u).host).exists? }.each do |u|
      # spawn a new thread for each url
      threads << Thread.new do
        previews.push fetch(u)
      end
    end
    threads.each { |t| t.join }
    previews.compact
  rescue SocketError, URI::InvalidURIError, HTTParty::UnsupportedURIScheme, HTTParty::RedirectionTooDeep
    []
  end
end
