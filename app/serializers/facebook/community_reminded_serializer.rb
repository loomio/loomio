class Facebook::CommunityRemindedSerializer < Facebook::BaseSerializer
  def link
    polymorphic_url(object.poll, default_url_options.merge(host: "https://renhwsaevk.localtunnel.me"))
  end
end
