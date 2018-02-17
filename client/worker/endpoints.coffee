module.exports =
  assetEndpoints: (version) ->
    [
      "/dashboard",
      "/api/v1/boot/site",
      "/api/v1/translations?lang=en",
      "/client/fonts/materialdesignicons-webfont.woff2?v=2.1.19",
      "/theme/default_group_logo.png",
      ("/client/#{version}/angular.css"                            if version == 'development'),
      ("http://localhost:4002/client/#{version}/angular.bundle.js" if version == 'development'),
      ("/client/#{version}/angular.min.css"                        if version != 'development'),
      ("/client/#{version}/angular.bundle.min.js"                  if version != 'development')
    ].filter(Boolean)

  cachedEndpoints: [
    /img\/emoji/
  ]

  networkFirstEndpoints: [
    /api\/v1\/inbox/
  ]
