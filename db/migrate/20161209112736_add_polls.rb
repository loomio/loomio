class AddPolls < ActiveRecord::Migration
  def change
    create_table   :polls do |t|
      t.belongs_to :poll_template
      t.belongs_to :author
      t.belongs_to :outcome_author
      t.string     :outcome
      t.string     :name
      t.text       :description
      t.timestamps
    end

    create_table   :poll_options do |t|
      t.belongs_to :poll_template
      t.string     :name
      t.string     :icon_url
    end

    create_table   :poll_poll_options do |t|
      t.belongs_to :poll
      t.belongs_to :poll_option
    end

    create_table   :poll_templates do |t|
      t.string     :name
      t.timestamps
    end

    create_table   :stances do |t|
      t.belongs_to :poll
      t.belongs_to :poll_option
      t.integer    :participant_id
      t.string     :participant_type
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
      t.belongs_to :poll
      t.belongs_to :community
    end

    create_table   :communities do |t|
      t.string     :community_type
      t.jsonb      :custom_fields, null: false, default: {}
      t.timestamps
    end

  end
end
