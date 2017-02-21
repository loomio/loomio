class AddPolls < ActiveRecord::Migration
  def change
    create_table   :polls do |t|
      t.belongs_to :poll_template
      t.belongs_to :author, null: false
      t.belongs_to :outcome_author
      t.string     :outcome
      t.string     :name, null: false
      t.text       :description
      t.boolean    :allow_custom_options, null: false, default: false
      t.datetime   :closing_at
      t.datetime   :closed_at
      t.timestamps
    end

    create_table   :poll_options do |t|
      t.belongs_to :poll_template
      t.string     :name, null: false
      t.string     :icon_url
    end

    create_table   :poll_poll_options do |t|
      t.belongs_to :poll, null: false
      t.belongs_to :poll_option, null: false
    end

    create_table   :poll_templates do |t|
      t.string     :name, null: false
      t.boolean    :allow_custom_options, null: false, default: false
      t.timestamps
    end

    create_table   :stances do |t|
      t.belongs_to :poll, null: false
      t.belongs_to :poll_option, null: false
      t.integer    :participant_id, null: false
      t.string     :participant_type, null: false
      t.string     :statement
      t.boolean    :latest, null: false, default: true
      t.integer    :score, null: false, default: 1
      t.timestamps
    end

    create_table   :visitors do |t|
      t.string     :participation_token
      t.string     :name
      t.string     :email
      t.timestamps
    end

    create_table   :poll_communities do |t|
      t.belongs_to :poll, null: false
      t.belongs_to :community, null: false
    end

    create_table :poll_references do |t|
      t.integer    :reference_id, null: false
      t.string     :reference_type, null: false
      t.belongs_to :poll, null: false
    end

    create_table   :communities do |t|
      t.string     :community_type, null: false
      t.jsonb      :custom_fields, null: false, default: {}
      t.timestamps
    end

    add_column :groups, :community_id, :integer

  end
end
