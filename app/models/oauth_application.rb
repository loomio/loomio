class OauthApplication < Doorkeeper::Application
  has_attached_file :logo, styles: {square: "100x100#"}, default_url: 'img/default-logo-medium.png'
end
