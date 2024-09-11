# frozen_string_literal: true

require "middleware/spy_middleware"
Rails.application.config.middleware.use SpyMiddleware
