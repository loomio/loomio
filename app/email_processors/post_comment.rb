class PostComment
  include HTTParty
  base_uri ENV['LOOMIO_API_URL']

  def initialize(user_id: user_id,
                 email_api_key: api_key,
                 comment_params: comment_params)

    @user_id = user_id
    @email_api_key = email_api_key
    @comment_params = comment_params
  end

  def now!
    self.class.post('/v1/comments/',
                    body: {comment: @comment_params},
                    headers: {'Loomio-User-Id' => @user_id,
                              'Loomio-Email-API-Key' => @email_api_key})
  end
end
