
class WebpushCertSerializer < ApplicationSerializer
  attributes :public_key
  def public_key
    object.public_key.delete('=')
  end
end
