module OnlineTagMigration
  private

  # Do not queue a schema lock behind live traffic for an unbounded time. A
  # failed attempt can be retried after its already committed steps are checked.
  def with_short_lock_wait
    previous = connection.select_value('SHOW lock_timeout')
    execute "SET lock_timeout = '1s'"
    yield
  ensure
    execute "SET lock_timeout = #{connection.quote(previous)}" if previous
  end
end
