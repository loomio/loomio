class Views::Admin::SpamRules::Show < Views::Admin::Layout
  def initialize(rule:, activity:)
    super(title: "Spam rule ##{rule.id}")
    @rule, @activity = rule, activity
  end

  def view_template
    page_header("Spam rule ##{@rule.id}", action_label: 'Edit rule', action_path: edit_admin_spam_rule_path(@rule))
    render Views::Admin::SpamRules::Explanation.new
    definition_list(@rule, [ :kind, :pattern, :reason, :state, :expires_at, :discarded_at ]) do |key, field_value|
      key == :kind ? SpamRule::KINDS.fetch(field_value) : value(field_value)
    end
    if @rule.discarded?
      button_to 'Restore rule', restore_admin_spam_rule_path(@rule), method: :patch, class: 'admin-button'
    else
      button_to 'Disable rule', disable_admin_spam_rule_path(@rule), method: :patch, class: 'admin-button'
    end
    panel('Blocked actions') do
      table(class: 'admin-table') do
        thead { tr { [ 'Action', 'Last hour', '24 hours', '30 days', 'Last blocked' ].each { |heading| th { heading } } } }
        tbody do
          SpamRuleHit::ACTIONS.each do |action|
            row = @activity.find { |entry| entry[1] == action }
            tr do
              td { action.humanize }
              [ 2, 3, 4 ].each { |index| td { (row ? row[index] : 0).to_i.to_s } }
              td { value(row&.last&.iso8601) }
            end
          end
        end
      end
    end
    panel('Change history (latest 50 changes)') do
      @rule.versions.order(id: :desc).limit(50).each do |version|
        p { "#{version.created_at.iso8601} · #{version.event} · User #{version.whodunnit || 'system'}" }
        div(class: 'admin-table-wrap') do
          table(class: 'admin-table') do
            thead { tr { [ 'Field', 'Before', 'After' ].each { |heading| th { heading } } } }
            tbody do
              version.changeset.except('id', 'created_at', 'updated_at').each do |field, (before, after)|
                tr do
                  td { field.humanize }
                  td { value(before) }
                  td { value(after) }
                end
              end
            end
          end
        end
      end
    end
  end
end
