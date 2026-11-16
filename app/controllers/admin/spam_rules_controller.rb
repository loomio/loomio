class Admin::SpamRulesController < Admin::BaseController
  before_action :set_paper_trail_whodunnit
  before_action :load_rule, only: %i[show edit update disable restore]

  def index
    filters = params.permit(:kind, :state, :q).to_h
    rules = SpamRule.order(id: :desc)
    rules = rules.where(kind: filters['kind']) if filters['kind'].present?
    rules = case filters['state']
    when 'active' then rules.active
    when 'disabled' then rules.discarded
    when 'expired' then rules.kept.where('expires_at <= ?', Time.current)
    else rules
    end
    if filters['q'].present?
      value = "%#{SpamRule.sanitize_sql_like(filters['q'])}%"
      rules = rules.where('pattern ILIKE ? OR reason ILIKE ?', value, value)
    end
    rules, pagination = paginate(rules)
    render Views::Admin::SpamRules::Index.new(rules: rules, pagination: pagination, filters: filters,
      activity: SpamRuleHit.activity(rules.map(&:id)))
  end

  def show
    render Views::Admin::SpamRules::Show.new(rule: @rule, activity: SpamRuleHit.activity([ @rule.id ]).fetch(@rule.id, []))
  end

  def new
    render Views::Admin::SpamRules::Edit.new(rule: SpamRule.new(kind: 'email_domain'))
  end

  def create
    @rule = SpamRule.new(rule_params)
    if @rule.save
      redirect_to admin_spam_rule_path(@rule), notice: 'Spam rule added'
    else
      render Views::Admin::SpamRules::Edit.new(rule: @rule), status: :unprocessable_entity
    end
  end

  def edit
    render Views::Admin::SpamRules::Edit.new(rule: @rule)
  end

  def update
    if @rule.update(rule_params)
      redirect_to admin_spam_rule_path(@rule), notice: 'Spam rule updated'
    else
      render Views::Admin::SpamRules::Edit.new(rule: @rule), status: :unprocessable_entity
    end
  end

  def disable
    @rule.discard! unless @rule.discarded?
    redirect_to admin_spam_rule_path(@rule), notice: 'Spam rule disabled'
  end

  def restore
    @rule.undiscard! if @rule.discarded?
    redirect_to admin_spam_rule_path(@rule), notice: 'Spam rule restored'
  end

  def test_pattern
    value = params.fetch(:value, '').to_s.first(4096)
    target = params.fetch(:target, 'email').to_s
    raise ActionController::BadRequest unless %w[email ip content].include?(target)
    matches = SpamRule.active.order(:id).select { |rule| rule.matches?(value, target: target.to_sym) }
    render Views::Admin::SpamRules::Test.new(value: value, target: target, matches: matches)
  end

  private

  def load_rule
    @rule = SpamRule.find(params[:id])
  end

  def rule_params
    params.require(:spam_rule).permit(:kind, :pattern, :reason, :expires_at)
  end
end
