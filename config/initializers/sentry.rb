# frozen_string_literal: true

SENTRY_DSN = ENV.fetch('SENTRY_DSN', Rails.application.secrets.sentry_dsn)

if SENTRY_DSN.present?
  Sentry.init do |config|
    config.dsn = SENTRY_DSN
    config.breadcrumbs_logger = %i[active_support_logger http_logger]

    config.traces_sample_rate = 1.0

    config.send_modules = false
  end
end
