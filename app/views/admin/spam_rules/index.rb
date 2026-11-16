class Views::Admin::SpamRules::Index < Views::Admin::Layout
  def initialize(rules:, pagination:, filters:, activity:)
    super(title: 'Spam rules')
    @rules, @pagination, @filters, @activity = rules, pagination, filters, activity
  end

  def view_template
    page_header('Spam rules', action_label: 'Add rule', action_path: new_admin_spam_rule_path)
    render Views::Admin::SpamRules::Explanation.new
    form_with(url: admin_spam_rules_path, method: :get, class: 'admin-filter-bar') do |form|
      div(class: 'admin-filter-bar__search admin-field') do
        form.label(:q, 'Search patterns and reasons')
        form.search_field(:q, value: @filters['q'])
      end
      div(class: 'admin-field') do
        form.label(:kind, 'Rule type')
        form.select(:kind, [ [ 'All types', '' ] ] + SpamRule::KINDS.map { |kind, label| [ label, kind ] }, selected: @filters['kind'])
      end
      div(class: 'admin-field') do
        form.label(:state, 'State')
        form.select(:state, [ [ 'All states', '' ], [ 'Active', 'active' ], [ 'Expired', 'expired' ], [ 'Disabled', 'disabled' ] ], selected: @filters['state'])
      end
      form.submit('Filter', class: 'admin-button')
    end
    div(class: 'admin-table-wrap') do
      table(class: 'admin-table') do
        thead { tr { [ 'Type', 'Pattern', 'Reason', 'State', 'Expires', 'Last hour', '24 hours', '30 days', 'Last blocked' ].each { |heading| th { heading } } } }
        tbody do
          @rules.each do |rule|
            rows = @activity.fetch(rule.id, [])
            tr do
              td { SpamRule::KINDS.fetch(rule.kind) }
              td { link_to rule.pattern, admin_spam_rule_path(rule) }
              td { value(rule.reason) }
              td { rule.state }
              td { value(rule.expires_at&.iso8601) }
              [ 2, 3, 4 ].each { |index| td { rows.sum { |row| row[index] }.to_i.to_s } }
              td { value(rows.filter_map(&:last).max&.iso8601) }
            end
          end
        end
      end
    end
    pagination_links(@pagination, @filters)
    render Views::Admin::SpamRules::Test.new(value: '', target: 'email', matches: nil, embedded: true)
  end
end
