# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w(
  email.css
  web.css
  basic.css
  loomiosubs.css
  vtfy/typography.css
  vtfy/layout.css
  vtfy/round.css
  vtfy/components.css
  vtfy/themeauto.css
  active_admin.css
  active_admin.js
  active_admin/print.css
  admin.css
  admin.js
  poll_mailer/*.png
  *.png *.jpg *.jpeg *.gif *.svg)
