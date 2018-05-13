module PersonalDataHelper
  def count_and_link_to(table)
    "<a href=\"/personal_data/#{table}\">#{table}</a>".html_safe
  end
end
