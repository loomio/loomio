def i18n_params
  parsed = Nokogiri::HTML(body)
  {group:      parsed.css('.i18n-params .group').text,
   discussion: parsed.css('.i18n-params .discussion').text,
   voter:      parsed.css('.i18n-params .voter').text,
   poll:       parsed.css('.i18n-params .poll').text,
   title:     parsed.css('.i18n-params .poll').text,
   actor:   parsed.css('.i18n-params .actor').text}
end

def body
  # ActionMailer::Base.deliveries.last.body.parts.last.decoded
  response.body
end

def expect_text(selector, val)
  expect(Nokogiri::HTML(body).css(selector).to_s).to include val
end

def expect_text_no_tags(selector, val)
  expect(Nokogiri::HTML(body).css(selector).text).to include val
end

def expect_no_text(selector, val)
  expect(Nokogiri::HTML(body).css(selector).to_s).length.to be 0
end

def expect_element(selector)
  expect Nokogiri::HTML(body).css(selector).to_s.length > 0
end

def expect_no_element(selector)
  expect Nokogiri::HTML(body).css(selector).to_s.length == 0
end

def expect_subject(key)
  expect(Nokogiri::HTML(body).css('.poll-mailer__subject').to_s).to include I18n.t(key, i18n_params)
end
