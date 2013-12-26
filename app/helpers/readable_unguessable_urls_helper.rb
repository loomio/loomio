module ReadableUnguessableUrlsHelper

  def discussion_path(discussion, options={})
    discussion_url(discussion, options.merge(:only_path => true))
  end

  def discussion_url(discussion, options={})
    options.merge!(host_and_port)

    options.merge! controller: '/discussions', action: 'show',
                   id: discussion.key, slug: discussion.title.parameterize
    url_for(options)
  end

  def group_path(group, options={})
    group_url(group, options.merge(:only_path => true))
  end

  def group_url(group, options={})
    options.merge!(host_and_port)

    options.merge! :controller => '/groups', :action => 'show',
                   :id => group.key, :slug => group.full_name.parameterize
    url_for(options)
  end


  private
  def host_and_port
    if request.present?
      {host: request.host, port: request.port}
    else
      ActionMailer::Base.default_url_options
    end
  end
end
