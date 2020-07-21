Warning.singleton_class.prepend(
  Module.new do
    RUBY_27_WARNINGS = Regexp.union(
      %r{warning: Using the last argument as keyword parameters is deprecated},
      %r{warning: Passing the keyword argument as the last hash parameter is deprecated},
      %r{warning: Splitting the last argument into positional and keyword parameters is deprecated},
      %r{warning: The called method( `.+')? is defined here},
    )

    RUBY_27_WARNINGS_FROM_GEMS = Regexp.union(
      %r{/gems/.* warning: Using the last argument as keyword parameters is deprecated},
      %r{/gems/.* warning: Passing the keyword argument as the last hash parameter is deprecated},
      %r{/gems/.* warning: Splitting the last argument into positional and keyword parameters is deprecated},
      %r{/gems/.* warning: The called method( `.+')? is defined here},
      %r{warning: URI.escape is obsolete}
    )

    def warn(warning)
      return if warning.match?(RUBY_27_WARNINGS_FROM_GEMS)
      return if warning.match?(RUBY_27_WARNINGS) && (Rails.env.development? || Rails.env.production?)

      super
    end
  end
)
