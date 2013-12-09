class PermittedDiscussionRoutes
  GET_ACTIONS    = %w[ new_proposal ]
  POST_ACTIONS   = %w[ update_description add_comment show_description_history edit_title ]
  PUT_ACTIONS    = %w[ move update ]
  DELETE_ACTIONS = %w[ ]

  def self.matches?(request)

    request_method = request.env['REQUEST_METHOD']
    action =         request.path_parameters[:action]

    puts POST_ACTIONS

    raise "::#{request_method}_ACTIONS".constantize.inspect #constantize.include? action

  # post   '/d/:key/:slug/update_description',       to: 'discussions#update_description'
  # post   '/d/:key/:slug/add_comment',              to: 'discussions#add_comment'
  # post   '/d/:key/:slug/show_description_history', to: 'discussions#show_description_history'
  # get    '/d/:key/:slug/new_proposal',             to: 'discussions#new_proposal'
  # post   '/d/:key/:slug/edit_title',               to: 'discussions#edit_title'
  # put    '/d/:key/:slug/move',                     to: 'discussions#move'

  # get    '/d/:key/:slug',                    to: 'discussions#show' #note the * here is dangerous, this GET needs to be specified last
  # put    '/d/:key/:slug/update',             to: 'discussions#update'
  # delete '/d/:key/:slug',                    to: 'discussions#destroy'


  end
end