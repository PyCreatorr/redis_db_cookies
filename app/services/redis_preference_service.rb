class RedisPreferenceService
    require 'securerandom'

    def self.sessionId
        secureR = SecureRandom.hex(3)

        puts "Generated secure random!!!!! =, #{secureR}"
        return secureR
    end

    def self.sessionsKey(sessionId)
        @sessionsKey = "sessions##{sessionId}"
    end

    def self.usersKey(userId)
        @usersKey = "users##{userId}"
    end

    def self.usernamesKey()
        @usernamesKey="usernames"
    end

    def self.usernamesUniqueKey()
        @usernamesUniqueKey = "usernames:unique"
    end

    def self.idsUniqueKey()
        @idsUniqueKey = "ids:unique"
    end

    def self.sessionIdKey(sessionId)
        @sessionIdKey = "HyperLogLog##{sessionId}"
    end
    
    # Posts
    def self.postsKey(postId)
        @postsKey = "posts##{postId}"
    end

    def self.postsAllKey()
        @postsAlley="posts"
    end


    

    # export const usernamesKey = () => 'usernames';

    # def self.saveSession(session)
    #     @redis = RedisService.set_redis()

    #     savedS = @redis.hSet(self.sessionsKey(session.id), self.serialize(session))
       
    #     puts "YOUR SAVED SESSION =, #{self.getSession(session.id)}"

    #     return savedS     
    # end

    # def self.getSession(id)
    #     @redis = RedisService.set_redis()

    #     session = @redis.hGetAll(self.sessionsKey(id));

    #     return null if(session.length == 0)

    #     puts "WE'VE GET SESSION =, #{self.getSession(session.id)}"

    #     return self.deserialize(id,session)

    #     #return @redis.hSet(self.sessionsKey(session.id), self.serialize(session))     
    # end


    # def self.serialize(session)
    #     return {
    #         userId: session.userId, 
    #         username: session.username 
    #     }
    # end

    # def self.deserialize(id,session)
    #     return {
    #         id:id,
    #         userId: session.userId,
    #         username: session.username
    #     }
    # end


end