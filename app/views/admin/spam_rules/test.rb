class Views::Admin::SpamRules::Test < Views::Admin::Layout
  def initialize(value:, target:, matches:, embedded: false)
    super(title: 'Test spam rules')
    @value, @target, @matches, @embedded = value, target, matches, embedded
  end

  def around_template(&block)
    @embedded ? yield : super(&block)
  end

  def view_template
    panel('Test a value') do
      form_with(url: test_pattern_admin_spam_rules_path, method: :post, class: 'admin-form') do |form|
        form.label(:target, 'Value type')
        form.select(:target, [ [ 'Email address', 'email' ], [ 'IP address', 'ip' ], [ 'Content', 'content' ] ], selected: @target)
        field(form, :value, value: @value, maxlength: 4096)
        form.submit('Test value', class: 'admin-button')
      end
      unless @matches.nil?
        p { @matches.empty? ? 'No active rules match this value' : 'Matching active rules:' }
        @matches.each do |rule|
          p do
            link_to "#{rule.id}: #{rule.pattern}", admin_spam_rule_path(rule)
            plain " · #{rule.match_error}" if rule.match_error
          end
        end
      end
    end
  end
end
