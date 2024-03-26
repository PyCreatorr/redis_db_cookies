class GuestPreferenceService

  # require 'language/lua'

  # before_action :set_redis, only: [:update_guest_preferences]
  PREFERENCE_KEYS = [:post_order, :other_preference].freeze

  # require 'redis'
  
    # READ & STORE THE KEYS IN THE COOKIES
    def self.update_guest_preferences(cookies, preferences)  


      # :post_order => "newest" # key , value
      # self.set_redis()

      # @redis = RedisService.set_redis()
      # @redis.set("mykey1", "hello world from services update quest preferences")
      # g = @redis.get("mykey")
      # puts "Check redis from registrations controller, mykey = #{g}"

      # puts "COOKIES TO HASH! = #{cookies.to_hash}"

      # all_cookies = cookies.to_hash
      # puts "Session value === #{all_cookies['_cookie_storage_session'] }"

      # all_cookies.each do |name, value|
      #   puts "Cookie Name: #{name}, Value: #{value}"
      # end

      #decrypted_cookies = cookies.encrypted['_app_session_store']
      session_id = cookies.encrypted['_app_session_store']['session_id']

      puts "SessionId= #{session_id}"


      
      # puts "SessionId= #{decrypted_cookies['session_id']}"
      # session_id = decrypted_cookies['session_id']

      @redis = RedisService.set_redis()

      # math.randomseed(tonumber(ARGV[2]))

      random_push_script = "
      local i = tonumber(ARGV[1])
      local res      
      while (i > 0) do
          res = redis.call('LPUSH',KEYS[1],math.random())
          i = i-1
      end
      return res
     "

      n_script = "return redis.call('SET',KEYS[1],1 + tonumber(ARGV[1]))"

      hyper_log_log_complete = "
      local itemsViewsKey = KEYS[1]
      local itemsKey = KEYS[2]
      local itemsByViewsKey = KEYS[3]

      local itemId = ARGV[1]
      local userId = ARGV[2]

      local inserted = redis.call('PFADD',itemsViewsKey,userId)

      if inserted == 1 then
        redis.call('HINCRBY',itemsKey,'views',1)
        redis.call('ZINCRBY',itemsByViewsKey,1,itemId)
      end
      "

     hyper_log_log_short = "
     local session_id = KEYS[1]
     local memberSortedSetIncrBy = KEYS[2]

     local argToIncrease = ARGV[1]
     local minRange = ARGV[2]
     local maxRange = ARGV[3]

     local inserted = redis.call('PFADD',session_id,argToIncrease)

     if inserted == 1 then       
      redis.call('ZINCRBY',memberSortedSetIncrBy,1,argToIncrease)
     end

     return redis.call('ZRANGE',memberSortedSetIncrBy,minRange,maxRange,'WITHSCORES')
     "
     # return redis.call('ZRANGE',memberSortedSetIncrBy,minRange,maxRange,'WITHSCORES')
     # return redis.call('ZSCORE',memberSortedSetIncrBy,argToIncrease)

     # keyIncrBy =  "views##{session_id}"
      keyIncrBy = "views_total#with_sessions"

      puts "keyIncrBy= #{keyIncrBy}"

      #  inf_int = 2**63 - 1
      #  puts inf_int

      # Integer(Float::INFINITY)
      minInf = -2**63
      maxInf = 2**63-1 
      puts minInf
      puts maxInf

      puts "hyperloglog = #{@redis.eval(hyper_log_log_short,[session_id,keyIncrBy], [session_id,minInf,maxInf])}" 

      #puts "zRANGE = #{@redis.zRange(keyIncrBy,0,10,'WITHSCORES')}" 


      #puts "hyperloglogTOTAL = #{@redis.zScore(keyIncrBy, {key=>value})}" 
      #@redis.del(:mylist)

      books = 'books:count'

      puts "LLL = #{@redis.eval(n_script,[:books], [5])}"

      puts "LUAAA = #{@redis.get('books:count')}"


      #puts "Lua Lua = #{@redis.eval(random_push_script,[:mylist],[10,rand(2**32)])}"

      #puts "Lua Lua = #{@redis.eval(random_push_script,1,[:mylist],[10,rand(2**32)])}"

      #puts "LUAAA = #{@redis.lrange('mylist', 0, -1)}"

      # lua = Language::Lua.new()
      # lua.eval("script.lua")


      # puts lua.eval("return table.concat({ 'hello', 'from', 'Lua' }, ' ')")
      
      # out = lua.my_lua_function( 'return redis.call('SET', KEYS[1], 1 + tonumber(ARGV[1])) ')

    

      # @redis.addOneAndStore('books:count', 5)
      # result = @redis.get('books:count')
      # puts "!!!!!!result=' #{result}"

      preferences.each do |key, value|
        cookies.permanent[key] = value
        puts "Guest preference service, cookies.permanent[#{key}] = #{value}" 

        @redis.hSet(RedisPreferenceService.sessionsKey(session_id), {key=>value}) if key == "post_order"
        
        # HyperLogLog
        # increment = @redis.pfAdd(RedisPreferenceService.sessionIdKey(session_id), session_id)
        # pfcount = @redis.pfCount(RedisPreferenceService.sessionIdKey(session_id))
        # puts "HyperLogLog pfcount #{session_id} = #{pfcount}"
        # puts "HyperLogLog added or not #{session_id} = #{increment}" 

      end

      puts "hmGet = #{@redis.hmGet(RedisPreferenceService.sessionsKey(session_id), "post_order")}"
      # puts "hGetAll = #{@redis.hGetAll(RedisPreferenceService.sessionsKey(session_id))}"

      @redis.close();

    end

    # METHOD FOR THE app/controllers/users/sessions_controller.rb
     # DELETE GUESTS COOKIES
     def self.delete_guest_preferences(cookies)
        PREFERENCE_KEYS.each do |key|
          cookies.delete(key)
          puts "Guest preference service, cookies.delete(#{key})"
        end

        @redis = RedisService.set_redis()
        @redis.hdel(RedisPreferenceService.sessionsKey(cookies[:session_id]), "post_order")
        @redis.close()

     end

     


    # METHOD FOR THE app/controllers/users/sessions_controller.rb
     # CHECK IF THE PREFERENCES EXISTS
     def self.guest_preferences_present?(cookies)
       PREFERENCE_KEYS.any? { |key| cookies[key].present? }
     end

    # private
    #  def self.set_redis      
    #   @redis = Redis.new(host: ENV.fetch("REDIS_HOST"), port: ENV.fetch("REDIS_PORT"), password: ENV.fetch("REDIS_PW"))
    # end
  
  end