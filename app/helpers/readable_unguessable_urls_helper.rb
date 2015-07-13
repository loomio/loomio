module ReadableUnguessableUrlsHelper
  MODELS_WITH_SLUGS = { 'discussion' => :title,
                              'user' => :name,
                            'group'  => :full_name,
                            'motion' => :name }

  MODELS_WITH_SLUGS.keys.each do |model|
    model = model.to_s.downcase

    define_method("#{model}_url", ->(instance, options={}) {
      options = options.merge(only_path: false)
                       .merge(route_hash(instance, model) )

      url_for(options)
    })

    define_method("#{model}_path", ->(instance, options={}) {
      options = options.merge(only_path: true)
                       .merge(route_hash(instance, model) )

      url_for(options)
    })
  end


  private

  def route_hash(instance, model)
    controller = "/#{model.pluralize}"
    name = MODELS_WITH_SLUGS[model]
    slug = instance.send(name).parameterize
    { controller: controller, action: 'show', id: instance.key, slug: slug }
  end

end
