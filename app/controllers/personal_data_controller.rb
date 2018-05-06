class PersonalDataController < ActionController::Base
  layout "basic"
  
  def index
    # list and explain the tables we have for someone
  end

  def show
    # a particular table in html or json format
    @records = Queries::PersonalDataQuery.send(params_table, current_user)
  end

  def gdpr
  end

  private
  def params_table
    tables.detect{|t| t == params[:table]}
  end

  def tables
    (Queries::PersonalDataQuery.methods - Class.methods).map(&:to_s)
  end

  def host_name
    ENV['CANONICAL_HOST']
  end
  # def count_and_link_to(table)
  #   Queries::PersonalData.send(table).count
  #   link_to "view #{count} #{table} records",
  # end
end
