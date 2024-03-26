class RedisService

    require 'redis'

    def self.set_redis    
        @redis = Redis.new(
            host: ENV.fetch("REDIS_HOST"), 
            port: ENV.fetch("REDIS_PORT"), 
            password: ENV.fetch("REDIS_PW"),
            ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }           

            # scripts: {
            #     addOneAndStore: defineScript({
            #         NUMBER_OF_KEYS: 1,
            #         SCRIPT: `
            #             return redis.call('SET', KEYS[1], 1 + tonumber(ARGV[1]))
            #         `,
            #         transformArguments(key:string, value: number){
            #             return [key, value.toString()]
            #             # ['books:count', 5]
            #             # EVALSHA <ID> 1 'books:count' '5'
            #         },
            #         transformReply(reply: any){
            #             return reply
            #         }
            #     })
            # }
        
        )

        
    end
end