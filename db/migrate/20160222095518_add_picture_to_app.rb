class AddPictureToApp < ActiveRecord::Migration
  def change
    add_attachment :oauth_applications, :logo
  end
end
