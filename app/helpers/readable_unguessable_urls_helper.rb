module ReadableUnguessableUrlsHelper
  MODELS_WITH_SLUGS = { 'discussion' => :title,
                              'user' => :name,
                            'group'  => :full_name,
                            'motion' => :name }

  MODELS_WITH_SLUGS.keys.each do |model|
    next if model == 'group'
    model = model.to_s.downcase

    define_method("#{model}_url", ->(instance, options={}) {
      options = options.merge( host_and_port )
                       .merge( route_hash(instance, model) )

      url_for(options)
    })

    define_method("#{model}_path", ->(instance, options={}) {
      options = options.merge(only_path: true)

      self.send("#{model}_url", instance, options)
    })

  end

  def group_url(group, options = {})
    options = options.merge( host_and_port ).
                      merge( route_hash(group, 'group') )

    if request.present?
      options[:host] = request.domain
      options.delete(:subdomain)
    end

    if group.has_subdomain?
      options[:subdomain] = group.subdomain
      unless group.is_sub_group?
        uri = URI(url_for(options))
        uri.path = ''
        return uri.to_s
      end
    elsif ENV['DEFAULT_SUBDOMAIN']
      options[:subdomain] = ENV['DEFAULT_SUBDOMAIN']
    end

    url_for(options)
  end

  def group_path(group, options = {})
    #options = options.merge(only_path: true) unless group.has_subdomain?
    group_url(group, options)
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

  def route_hash(instance, model)
    controller = "/#{model.pluralize}"
    name = MODELS_WITH_SLUGS[model]
    slug = instance.send(name).parameterize

    { controller: controller, action: 'show', id: instance.key, slug: slug }
  end

end
