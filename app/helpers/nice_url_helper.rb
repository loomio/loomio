module NiceUrlHelper

  def discussion_path(discussion, options={})
    discussion_url(discussion, options.merge(:only_path => true))
  end

  def discussion_url(discussion, options={})
    options.reverse_merge! host: default_host_for_url,
                           port: default_port_for_url

    options.merge! controller: 'discussions', action: 'show',
                   id: discussion.key, slug: discussion.title.parameterize
    url_for(options)
  end

  def group_path(group, options={})
    group_url(group, options.merge(:only_path => true))
  end

  def group_url(group, options={})
    options.reverse_merge! host: default_host_for_url,
                           port: default_port_for_url

    options.merge! :controller => 'groups', :action => 'show',
                   :id => group.key, :slug => group.full_name.parameterize
    url_for(options)
  end


  private

  def default_host_for_url
    ENV['CANONICAL_HOST'] ? ENV['CANONICAL_HOST'] : 'localhost'
  end

  def default_port_for_url
    Rails.env.production? ? nil : ActionMailer::Base.default_url_options[:port]
  end

end
