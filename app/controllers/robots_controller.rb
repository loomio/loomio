class RobotsController < ActionController::Base
  # Signed-in areas and the API have nothing for crawlers. Exports stay crawlable
  # so crawlers can read their noindex directive.
  PRIVATE_PATHS = %w[/api/ /dashboard /inbox /notifications /profile /tasks /email_preferences].freeze

  def show
    lines = ["User-agent: *"]
    if ENV.key?('ALLOW_ROBOTS')
      lines << "Allow: /"
      lines += PRIVATE_PATHS.map { |path| "Disallow: #{path}" }
      lines << "Sitemap: #{sitemap_url(format: :xml)}"
    else
      lines << "Disallow: /"
    end
    render plain: lines.join("\n") + "\n"
  end
end
