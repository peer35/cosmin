Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  # The delayed_job worker (JOB_WORKER=true) runs without code reloading:
  # delayed_job reloads the app between jobs when cache_classes is false, which
  # breaks Rails 8 lazy route loading (devise_for -> User -> Blacklight::User).
  job_worker = ENV['JOB_WORKER'] == 'true'

  config.cache_classes = job_worker

  # Do not eager load code on boot (except for the job worker).
  config.eager_load = job_worker
  # rake tasks (e.g. jobs:work) skip eager loading unless this is set too
  config.rake_eager_load = job_worker

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true
  config.assets.compile = true
  config.assets.digest = false

  config.assets.enabled = true
  config.assets.paths << Rails.root.join('/app/assets/fonts')

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::FileUpdateChecker

  config.active_record.use_yaml_unsafe_load = true # This is a temporary fix for the following error: "Psych::DisallowedClass: Tried to load unspecified class: Time"
end