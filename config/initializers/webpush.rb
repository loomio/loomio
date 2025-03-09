Rails.application.config.after_initialize do
  if WebpushCert.count == 0
    Rails.application.config.vapid_key = WebPush.generate_key
    WebpushCert.create(public_key: Rails.application.config.vapid_key.public_key, private_key: Rails.application.config.vapid_key.private_key)
  else
    cert = WebpushCert.first

    Rails.application.config.vapid_key = {
      private_key: cert.private_key,
      public_key: cert.public_key
    }
  end
end



