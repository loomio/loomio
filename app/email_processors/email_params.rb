class EmailParams
  attr_accessor :discussion_id
  attr_accessor :user_id
  attr_accessor :parent_id
  attr_accessor :email_api_key
  attr_accessor :body

  def initialize(email, reply_host: ENV['REPLY_HOSTNAME'] || ENV['CANONICAL_HOST'])
    email_hash = email.to.select{|h| h[:host] == reply_host }.first || {}
    params = {}

    email_hash[:token].to_s.split('&').each do |segment|
      key_and_value = segment.split('=')
      params[key_and_value[0]] = key_and_value[1]
    end

    @discussion_id = params['d']
    @user_id       = params['u']
    @parent_id     = params['c']
    @email_api_key = params['k']
    @body          = email.body
  end
end
