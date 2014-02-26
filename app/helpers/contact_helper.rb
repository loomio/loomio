module ContactHelper
  def contact_destinations
    ContactMessage::DESTINATIONS.map { |destination| [t("contact_page.destinations.#{destination}"), destination] }
  end
end
