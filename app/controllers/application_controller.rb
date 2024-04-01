class ApplicationController < ActionController::Base
    helper_method :current_user, :user_signed_in?
    def current_user
        # super
        # Memoization of the current_user. If current_user is defined, give back, don't query db.
        # If not -> query db (find user)

        # const user = await client.hGetAll(usersKey(id))
        # get userby id from redis
       
        # @current_user ||= User.find(session[:user_id]) if session[:user_id] 

        c_user = nil
        
        if session[:user_id] && !@current_user.present?
            @redis = RedisService.set_redis()
            userHashes = @redis.hGetAll(RedisPreferenceService.usersKey(session[:user_id]))
            @redis.close()

            c_user=User.new(id: session[:user_id], email: userHashes[1], password: userHashes[3], encrypted_password: userHashes[3])
            # c_user.create_preference({post_order: userHashes[5]})   
            
            pref = Preference.new(id: session[:user_id], post_order: userHashes[5], user_id: c_user.id)
            
            c_user.preference = pref
            
            @current_user = c_user if c_user
            return @current_user
            puts "THAT SHOULD NOT APPEAR!!!"
        

        elsif session[:user_id] && @current_user.present?
            @redis = RedisService.set_redis()
            userHashes = @redis.hGetAll(RedisPreferenceService.usersKey(session[:user_id]))
            @redis.close()

            pref = Preference.new(id: session[:user_id], post_order: userHashes[5], user_id: @current_user.id)
            
            @current_user.preference = pref
            return @current_user
            puts "THAT SHOULD NOT APPEA2R!!!"
        # debugger

        end


        puts "WHEN THE USER IS NOT SIGNED IN & HAVE NO SESSION!! #{session[:user_id]}"

        @current_user ||= c_user if c_user
        #@current_user = c_user if c_user
             
    end

    def user_signed_in?
        # convert returned data from current_user into boolean:
        !!current_user 
    end

    # check if the user logged in, and if not -> redirect to login page
    def require_user
        if !user_signed_in?
          flash[:danger] = "You must be logged in to perform this action"
          redirect_to new_user_session_path
        end
    end

    # def devise_current_user
    #     @devise_current_user ||= warden.authenticate(scope: :user)
    #   end
      
    #   def current_user
    #     if params[:user_id].blank?
    #       devise_current_user
    #     else
    #       User.find(params[:user_id])
    #     end   
    #   end
      
    # helper_method :set_redis

    # private
    # def set_redis    
    #   @redis = Redis.new(host: ENV.fetch("REDIS_HOST"), port: ENV.fetch("REDIS_PORT"), password: ENV.fetch("REDIS_PW"))
    # end
end
