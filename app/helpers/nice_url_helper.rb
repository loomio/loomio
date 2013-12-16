module NiceUrlHelper

  def default_host_for_url
    ENV['CANONICAL_HOST'] ? ENV['CANONICAL_HOST'] : 'localhost'
  end

  def default_port_for_url
    Rails.env.development? ? ActionMailer::Base.default_url_options[:port] : nil
  end

end