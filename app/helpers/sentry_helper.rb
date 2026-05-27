module SentryHelper
  def set_sentry_context
    Sentry.configure_scope do |scope|
      scope.set_user(id: current_user.id, ip_address: request.remote_ip)
      scope.set_tags(email: current_user.email, name: current_user.name)
      scope.set_context("request", {
        path: request.filtered_path,
        params: request.filtered_parameters.slice(
          "id",
          "key",
          "topic_id",
          "discussion_id",
          "discussion_key",
          "poll_id",
          "poll_key",
          "event_id",
          "comment_id",
          "group_id",
          "user_id",
          "from",
          "order",
          "order_by",
          "parent_id",
          "sequence_id",
          "sequence_id_gt",
          "sequence_id_gte",
          "sequence_id_lt",
          "sequence_id_lte"
        )
      })
    end
  end
end
