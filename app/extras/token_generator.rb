TokenGenerator = Struct.new(:visitor) do
  def generate
    loop do
      @token = SecureRandom.hex(8)
      break unless Visitor.where(participation_token: @token).exists?
    end
    @token
  end
end
