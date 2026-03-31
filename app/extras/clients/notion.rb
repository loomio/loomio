class Clients::Notion
  NOTION_API_VERSION = "2022-06-28"
  NOTION_BASE_URL = "https://api.notion.com/v1"

  DATABASE_PROPERTIES = {
    "Title"  => { title: {} },
    "Event"  => { rich_text: {} },
    "Author" => { rich_text: {} },
    "URL"    => { url: {} },
    "Group"  => { rich_text: {} },
    "Type"   => { select: {} },
    "Status" => { select: {} },
    "Closing" => { date: {} }
  }.freeze

  def initialize(access_token:)
    @access_token = access_token
  end

  def create_database(page_id:, title:)
    response = HTTParty.post(
      "#{NOTION_BASE_URL}/databases",
      headers: headers,
      body: {
        parent: { type: "page_id", page_id: page_id },
        title: [{ type: "text", text: { content: title } }],
        properties: DATABASE_PROPERTIES
      }.to_json
    )

    unless response.success?
      Rails.logger.error "Notion API error: #{response.code} #{response.body}"
    end

    response
  end

  def create_page(database_id:, properties:)
    response = HTTParty.post(
      "#{NOTION_BASE_URL}/pages",
      headers: headers,
      body: {
        parent: { database_id: database_id },
        properties: properties
      }.to_json
    )

    unless response.success?
      Rails.logger.error "Notion API error: #{response.code} #{response.body}"
    end

    response
  end

  def update_page(page_id:, properties:)
    response = HTTParty.patch(
      "#{NOTION_BASE_URL}/pages/#{page_id}",
      headers: headers,
      body: { properties: properties }.to_json
    )

    unless response.success?
      Rails.logger.error "Notion API error: #{response.code} #{response.body}"
    end

    response
  end

  def find_page_by_loomio_id(database_id:, loomio_url:)
    response = HTTParty.post(
      "#{NOTION_BASE_URL}/databases/#{database_id}/query",
      headers: headers,
      body: {
        filter: {
          property: "URL",
          url: { equals: loomio_url }
        }
      }.to_json
    )

    return nil unless response.success?

    results = response.parsed_response["results"]
    results&.first
  end

  private

  def headers
    {
      "Authorization" => "Bearer #{@access_token}",
      "Content-Type" => "application/json",
      "Notion-Version" => NOTION_API_VERSION
    }
  end
end
