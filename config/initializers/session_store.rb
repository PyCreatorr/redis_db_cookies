# Rails.application.config.session_store :redis_store,
#                                        # servers: ['redis://localhost:6379/0/session'],
#                                        servers: ["#{ENV.fetch("REDIS_URL")}/0/session"],
#                                        expire_after: 90.minutes,
#                                        key: '_demo_devise_omniauth_session'


# Rails.application.config.session_store :cookie_store, key: '_cookie_storage_session'

# Rails.application.config.session_store :redis_store,
#                                        servers: ["#{ENV.fetch("REDIS_URL")}"],
#                                        expire_after: 90.minutes,
#                                        key: '_devise_redis_session'



# Configurations
# session_url = "#{ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379')}/0/session"

session_url = ENV.fetch("REDIS_URL")

secure = Rails.env.production?
key = Rails.env.production? ? "_app_session" : "_app_session_#{Rails.env}"
domain = ENV.fetch("DOMAIN_NAME", "localhost")

# Rails.application.config.session_store :redis_store,
#                                        url: session_url,
#                                        expire_after: 10.days,
#                                        key: "_app_session_store",
#                                        threadsafe: true,
#                                        secure: secure,
#                                        same_site: :lax,
#                                        httponly: true

Rails.application.config.session_store :cookie_store, key: ENV.fetch("SESSION_STORE_KEY"), expire_after: 14.days