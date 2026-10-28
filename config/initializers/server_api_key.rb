Rails.application.config.after_initialize { ServerApiKey.validate! }
