class DropSamlProviders < ActiveRecord::Migration[6.1]
  def change
    drop_table :saml_providers
  end
end
