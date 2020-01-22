module ApplicationHelper
  def vue_head
    vue_index = File.read(Rails.root.join('public/client/vue/index.html'))
    Nokogiri::HTML(vue_index).css('head').to_s
  end
  def vue_js
    vue_index = File.read(Rails.root.join('public/client/vue/index.html'))
    Nokogiri::HTML(vue_index).css('script').to_s
  end
end
