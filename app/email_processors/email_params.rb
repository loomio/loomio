class EmailParams
  attr_accessor :discussion_id
  attr_accessor :user_id
  attr_accessor :parent_id
  attr_accessor :parent_type
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

    if params['c'].present?
      @parent_id     = params['c']
      @parent_type   = "Comment" 
    end

    if params.fetch('p', '').split('-').length == 2
      letter, id = params['p'].split('-')
      class_name = {
        'p' => 'Poll',
        'c' => 'Comment',
        's' => 'Stance'
      }[letter]
      if class_name
        @parent_type   = class_name
        @parent_id     = id.to_i
      end
    end
    
    @email_api_key = params['k']
    @body          = email.body
  end
end
