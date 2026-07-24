class ApplicationPolicy
  attr_reader :context, :record

  def initialize(context, record)
    raise Pundit::NotAuthorizedError, "authorization context is required" unless context

    @context = context
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      raise Pundit::NotAuthorizedError, "authorization context is required" unless context

      @context = context
      @scope = scope
    end

    def resolve
      raise Pundit::NotDefinedError, "#{self.class} must implement #resolve"
    end
  end
end
