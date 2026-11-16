class Views::Admin::SpamRules::Edit < Views::Admin::Layout
  def initialize(rule:)
    super(title: rule.persisted? ? 'Edit spam rule' : 'Add spam rule')
    @rule = rule
  end

  def view_template
    page_header(@rule.persisted? ? 'Edit spam rule' : 'Add spam rule')
    render Views::Admin::SpamRules::Explanation.new
    url = @rule.persisted? ? admin_spam_rule_path(@rule) : admin_spam_rules_path
    form_with(model: @rule, url: url, method: @rule.persisted? ? :patch : :post, class: 'admin-form') do |form|
      form_errors(@rule, title: 'Spam rule could not be saved')
      div(class: 'admin-field') do
        form.label(:kind, 'Rule type')
        form.select(:kind, SpamRule::KINDS.map { |kind, label| [ label, kind ] })
      end
      field(form, :pattern)
      field(form, :reason)
      field(form, :expires_at, value: @rule.expires_at&.iso8601)
      p { 'Leave expiry empty for a rule without an end date. Include a timezone when entering a date, for example 2026-12-01T00:00:00Z.' }
      form.submit('Save rule', class: 'admin-button')
    end
  end
end
