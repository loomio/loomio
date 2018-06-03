module.exports =
  assetEndpoints: (version) ->
    [
      "/dashboard",
      "/manifest.json",
      "/api/v1/translations?lang=en",
      "/api/v1/boot/site",
      "/fonts/mdi-2.2.43/materialdesignicons-webfont.woff2?v=2.1.19",
      "/theme/default_group_logo.png",
      ("/client/#{version}/angular.css"                            if version == 'development'),
      ("/client/#{version}/angular.min.css"                        if version != 'development'),
      ("/client/#{version}/angular.bundle.min.js"                  if version != 'development')
    ].filter(Boolean)

  staticEndpoints: [
    /img\/emoji/
  ]

  networkFirstEndpoints: [
    /api\/v1\/boot\/user/
  ]
