Loomio::Application.config.session_store :cookie_store,
                                         key: '_loomio',
                                         secure: Loomio::Application.config.force_ssl
