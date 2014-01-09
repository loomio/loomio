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

  def user_path(user, options={})
    user_url(user, options.merge(:only_path => true))
  end

  def user_url(user, options={})
    options.merge!(host_and_port)
    options.merge! :controller => '/users', :action => 'show',
                   :id => user.key, :slug => user.name.parameterize
    url_for(options)
  end

  def motion_path(motion, options={})
    motion_url(motion, options.merge(:only_path => true))
  end

  def motion_url(motion, options={})
    options.merge!(host_and_port)
    options.merge! :controller => '/motions', :action => 'show',
                   :id => motion.key, :slug => motion.name.parameterize
    url_for(options)
  end

  def clean_url(url)
    uri = URI(url)
    query = uri.query.split('&').reject do |d|
      ['action', 'controller', 'slug'].include? d.split('=')[0]
    end
    uri.query = query.join('&')
    uri.to_s
  end

  private

  def host_and_port
    if request.present?
      if include_port?(request)
        { host: request.host, port: request.port }
      else
        { host: request.host, port: nil }
      end
    else
      ActionMailer::Base.default_url_options
    end
  end

  def include_port?(request)
    if    request.port == 80  && !request.ssl?
      false
    elsif request.port == 443 && request.ssl?
      false
    else
      true
    end
  end

end
