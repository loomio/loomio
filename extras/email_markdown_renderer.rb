class EmailMarkdownRenderer < Redcarpet::Render::HTML
  def header(text, level)
    level += 2
    "<h#{level}>#{text}</h#{level}>"
  end
end
