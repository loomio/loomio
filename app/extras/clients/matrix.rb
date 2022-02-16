class Clients::Matrix
  def initialize(server: , username:, password:, channel:)
    @server = server
    @username = username
    @password = password
    @channel = channel
  end

  def post_test_message
    in_room do |room|
      room.send_text I18n.t('webhook.hello')
    end
  end

  def in_room
    client = MatrixSdk::Client.new @server
    client.login(@username, @password)
    room = client.rooms.find {|r| r.name == @channel }
    yield(room)
    client.logout
  end
end
