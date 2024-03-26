redis = Redis.new(url: ENV['REDIS_HOST'],
    port: ENV['REDIS_PORT'],
    password: ENV['REDIS_PW'],
    db: ENV['REDIS_DB'])