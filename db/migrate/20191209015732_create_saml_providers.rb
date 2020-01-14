class CreateSamlProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :saml_providers
    add_column :saml_providers, :group_id, :integer, null: false
    add_column :saml_providers, :idp_metadata_url, :string, null: false
    add_column :saml_providers, :authentication_duration, :integer, null: false, default: 24
    add_index  :saml_providers, :group_id
  end
end
