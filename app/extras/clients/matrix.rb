class Clients::Matrix
  def initialize(server:, access_token:)
    @server = server.chomp("/")
    @access_token = access_token
  end

  def send_text(room_id_or_alias, text)
    room_id = join_room(room_id_or_alias)
    send_message(room_id, {msgtype: "m.notice", body: text})
  end

  def send_html(room_id_or_alias, html)
    room_id = join_room(room_id_or_alias)
    send_message(room_id, {
      msgtype: "m.text",
      body: ActionView::Base.full_sanitizer.sanitize(html),
      format: "org.matrix.custom.html",
      formatted_body: html
    })
  end

  # Joins a room by ID or alias. For private rooms this accepts a pending
  # invite. For rooms already joined this is a no-op on the server side.
  # Returns the canonical room ID.
  def join_room(room_id_or_alias)
    response = HTTParty.post(
      "#{@server}/_matrix/client/v3/join/#{CGI.escape(room_id_or_alias)}",
      headers: auth_headers.merge("Content-Type" => "application/json"),
      body: "{}",
    )
    response.parsed_response["room_id"] || room_id_or_alias
  end

  private

  def send_message(room_id, content)
    txn_id = SecureRandom.hex(16)
    HTTParty.put(
      "#{@server}/_matrix/client/v3/rooms/#{CGI.escape(room_id)}/send/m.room.message/#{txn_id}",
      headers: auth_headers.merge("Content-Type" => "application/json"),
      body: content.to_json
    )
  end

  def auth_headers
    {"Authorization" => "Bearer #{@access_token}"}
  end
end
