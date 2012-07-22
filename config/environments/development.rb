Chatty::Application.configure do
  config.threadsafe!

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers.
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models.
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL).
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Do not compress assets.
  config.assets.compress = false

  # Debug mode disables concatenation and preprocessing of assets.
  config.assets.debug = true

  # In development, use an in-memory queue for queueing
  config.queue = Rails::Queueing::Queue
end
