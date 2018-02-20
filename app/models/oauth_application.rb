class OauthApplication < Doorkeeper::Application
  has_attached_file :logo, styles: {square: "100x100#"}, default_url: AppConfig.theme[:icon_src]
  validates_attachment :logo,
    size: { in: 0..100.megabytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }
end
