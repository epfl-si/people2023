# frozen_string_literal: true

# # https://github.com/cyu/rack-cors
# if ENV['CORS_HOSTS']
#   Rails.application.config.middleware.insert_before 0, Rack::Cors do
#     allow do
#       origins (ENV['CORS_HOSTS']).to_s
#       resource '*', headers: :any, methods: %i[get post]
#     end
#   end
# end
