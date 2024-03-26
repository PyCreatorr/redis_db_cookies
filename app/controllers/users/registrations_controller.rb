# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :set_redis, only: [:create]

  # require 'redis'
  

  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # Create preferences after the user has done the registration and delete guests preferences
  def create
      @redis = RedisService.set_redis()      

      exists = @redis.sismember(RedisPreferenceService.usernamesUniqueKey(), params[:user][:email])
      
      # debugger
      if exists
        flash[:danger] = "Username is already taken"
        puts "Username is already taken" 
        
        @redis.close()
        return redirect_to root_path
      end



        puts "SESSON!! = #{session}" 

        puts "CURRENT_USER = #{current_user}" 

        #id = genId() # 1kfhr32643242332
        id = Random.new.rand(100000..10000000)

        # idExists = @redis.sismember(RedisPreferenceService.idsUniqueKey(), id.to_s)      
        # id = Random.new.rand(10000000000..1000000000000000000000) if idExists



        # Set the userId into the redis db. Register user
        @redis.sAdd(RedisPreferenceService.idsUniqueKey(), id.to_s)

        # Add preference to the user and save in db
        #params[:post_order] = { post_order: (cookies[:post_order] || "oldiest")}
        params[:post_order] = (cookies[:post_order] || "oldest")

        puts "registrations controller, preferences create = #{params[:post_order]}" 
        
        # Set the user into the redis db. Register user
        result = @redis.hSet(RedisPreferenceService.usersKey(id), serialize(params))

        puts "serialize(params) = #{serialize(params)}"

        puts "!!!@redis.hSet(RedisPreferenceService.usersKey(id) = #{result}"

        puts "RedisPreferenceService.usersKey(id) = #{RedisPreferenceService.usersKey(id)}" 

        # debugger

        # Add the username into the set of usernames. 
        # To check it quick out, wheter the new username is exists in the set.
        @redis.sAdd(RedisPreferenceService.usernamesUniqueKey(), params[:user][:email])

        # Create sorted set with the usernames and ids, converted into the number
        # @redis.zAdd(RedisPreferenceService.usernamesKey(), {score: (current_user.id).to_i, value: current_user.email});
        @redis.zAdd(RedisPreferenceService.usernamesKey(), id, params[:user][:email])

        @redis.close()
      
        # super


        # @redis.set("mykey", "hello world")
        #@redis = RedisService.set_redis()



        # session_id = cookies['_app_session_store']

        decrypted_cookies = cookies.encrypted['_app_session_store']
        session_id = decrypted_cookies['session_id']

        # Check if the username ia slready set in the set of usernames
        # If so, throw an error
        # Otherwise, continue
        
        # 0. Create usernamesUniqueKey
        # 1. Create a set of usernames
        # 2. Check
        # 3. Add username to the set of usernames
        
        # result is 1 or 0. DEVISE WILL CHEC THE USER. SO WE DON'T NEED THAT.

        # exists = @redis.sIsMember(RedisPreferenceService.usernamesUniqueKey(), params[:user][:email])

        build_resource(sign_up_params)

        # create and save the preferences in the db
        # resource.create_preference(preferences)
        
        # delete guest cookies
        GuestPreferenceService.delete_guest_preferences(cookies)
        puts "registrations controller, guest cookies deleted = #{cookies}" 


        ##### DEVISE PART. REGISTER USER 


        # resource.save

        #yield resource if block_given?

        

        user=User.new(id: id, email: params[:user][:email], password: params[:user][:password], encrypted_password: User.new(password: params[:user][:password]).encrypted_password)
        
        # user.create_preference({post_order: params[:post_order]})
        #user.preference({post_order: userHashes[5], user_id: user.id})

        pref = Preference.new(id: id, post_order: params[:post_order], user_id: id)
            
        user.preference = pref
        
        

         if user.present?
        #   if resource.active_for_authentication?
           set_flash_message! :notice, :signed_up

           warden.set_user(user, scope: :user)
           sign_up(:user, user)
           session[:user_id] = user.id

           # debugger
           redirect_to root_path
           #respond_with user, location: after_sign_up_path_for(user)
        #   else
        #     set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        #     expire_data_after_sign_in!
        #     respond_with resource, location: after_inactive_sign_up_path_for(resource)
        #   end
        else
          clean_up_passwords user
          set_minimum_password_length
          respond_with user
        end
        ##### DEVISE PART. REGISTER USER. END

        #redirect_to root_path
        
      end

  private

  def serialize(params)
      return {
          email: params[:user][:email],
          password: User.new(password: params[:user][:password]).encrypted_password,
          post_order: params[:post_order]
        }
  end

  # def deserialize(id,user)
  #     return { 
  #     id: id, 
  #     email: user.email, 
  #     password: user.password,
  #     post_order: user.post_order
  #     }
  # end

  def comparePasswords(password, encryptedPassword)
    decryptPass = Devise::Encryptable::Encryptors::Aes256.decrypt(encryptedPassword, Devise.pepper)
    return password == decryptPass
  end

  # private
  # def set_redis    
  #   @redis = Redis.new(host: ENV.fetch("REDIS_HOST"), port: ENV.fetch("REDIS_PORT"), password: ENV.fetch("REDIS_PW"))
  # end  

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
