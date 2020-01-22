module ApplicationHelper
  def vue_css_includes
    vue_index = File.read(Rails.root.join('public/client/vue/index.html'))
    Nokogiri::HTML(vue_index).css('head link').map {|el| el.attr(:href) }
  end
  def vue_js_includes
    vue_index = File.read(Rails.root.join('public/client/vue/index.html'))
    Nokogiri::HTML(vue_index).css('script').map {|el| el.attr(:src) }
  end
end
