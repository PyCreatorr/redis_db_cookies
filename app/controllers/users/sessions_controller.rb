# frozen_string_literal: true
class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
   def new
     #super
     # @users = User.order(:id).collect { |user| [user.username, user.id] }

    #  puts "SESSON_ NEW_GET = #{session}" 

    #  puts "SESSON_GET_USER_ID = #{session[:user_id]}" 

     # puts "CURRENT_USER_ID = #{current_user.id}"

     #self.resource = resource_class.new(sign_in_params)
     self.resource = User.new()
     clean_up_passwords(resource)
     #yield resource if block_given?
     #respond_with(resource, serialize_options(resource))

   end

  # POST /resource/sign_in
  def create

    @redis = RedisService.set_redis()

    #exists = @redis.sismember(RedisPreferenceService.usernamesUniqueKey(), params[:user][:email])

    # Use the username to look into the persons User Id in the "usernames" sorted set
    # Get the score. If it is not null

    id = @redis.zScore(RedisPreferenceService.usernamesKey(), params[:user][:email])

    # debugger
    
    
    if !id
       flash[:danger] = "Username does not exist"
      #return redirect_to root_path
    end

    userHashes = @redis.hGetAll(RedisPreferenceService.usersKey(id))

    if userHashes == []
      flash[:danger] = "User is not fount in db"
      puts "User is not fount in db, id = #{id}"
      return redirect_to root_path
    end

    puts "userHash!! = #{userHashes}" 

    # debugger
    # user_obj = userHashes.map do |_, user_hash|  
    #   { email: user_hash['email'], password: user_hash['password']}
    # end

    #user_obj=User.new(id: id, email: userHashes[1], password: userHashes[3], created_at: "2024-03-18 17:15:16.650849000 +0000", updated_at: "2024-03-18 17:15:16.650849000 +0000")
    user=User.new(id: id, email: userHashes[1], password: userHashes[3], encrypted_password: userHashes[3])


    puts "user_obj!! = #{user}" 
    

    ############# DEVISE --------
    checkPass = comparePasswords(params[:user][:password], user.encrypted_password)

    if checkPass == false
      #if options[:now]
        flash.now[:alert] = "Password is wrong!"
    # else
        flash[:alert] = "Password is wrong!"
      #end
      #flash[:danger] = "Password is wrong!"
      return redirect_to new_user_session_path
    end


    current_user = user

    @user = user
    #warden = env['warden']

    
   

    #self.resource = user
    set_flash_message!(:notice, :signed_in)
    
    
    #sign_in(resource_name, resource)
    #sign_in(user_obj, resource)

    warden.set_user(@user, scope: :user)
    sign_in(:user, @user)



    session[:user_id] = @user.id

    # puts "user_signed_in? = #{user_signed_in?}" 

    puts "current_user = #{@user}"



    if resource


        puts "SESSON!! = #{session}" 
    
        #puts "CURRENT_USER = #{current_user.email}" 
        #puts "CURRENT_USER_id = #{current_user.id}" 


        # decrypted_cookies = cookies[ENV.fetch("SESSION_STORE_KEY")]
        # session_id = decrypted_cookies['session_id']
    
        # session_id = cookies['_app_session_store']

        # puts "session_id = #{session_id}"
        puts "session_warden = #{session["warden.user.user.key"]}"

        
        # debugger
        # Check if the username ia slready set in the set of usernames
        # If so, throw an error
        # Otherwise, continue
        
        # 0. Create usernamesUniqueKey
        # 1. Create a set of usernames
        # 2. Check
        # 3. Add username to the set of usernames
        
        # result is 1 or 0
        # exists = @redis.sIsMember(session_id, params[:user][:email]);


    
        # Set the user into the redis db. Register user
        # @redis.hSet(usersKey(id), serialize(attrs));

        
        
        
        #warden.session(:user)[:redirect_back] = root_path
        
        # yield resource if block_given?
        #respond_with resource, location: after_sign_in_path_for(resource)
        

        
        
        if GuestPreferenceService.guest_preferences_present?(cookies)
          # ADD post_order to the params and save in redis hash user#id
          params[:post_order] = cookies[:post_order]
          
          GuestPreferenceService.delete_guest_preferences(cookies)
          puts "sessions controller, guest cookies deleted = #{cookies}" 
        end
        @redis.hSet(RedisPreferenceService.usersKey(@user.id), serialize(@user, params))        
        
        @redis.close()
        
        # debugger

        redirect_to root_path

      #   redirect_to root_path
      # else
      #   redirect_to new_user_session_path
    end

    # if resource.persisted? && GuestPreferenceService.guest_preferences_present?(cookies)
    #   GuestPreferenceService.delete_guest_preferences(cookies)
    #   puts "sessions controller, guest cookies deleted = #{cookies}" 
    # end

  end
  # DELETE /resource/sign_out
  def destroy
    super
    session[:user_id] = nil
    current_user = nil
    flash[:success] = "Logged out"
    
    debugger
    redirect_to root_path
  end

  private

  def deserialize_from_redis(hash)
    User.new(hash['email'], hash['encrypted_password'])
  end

  def serialize(user, params)
      if params[:post_order].present?
        return {
            email: user.email,
            password: User.new(password: params[:user][:password]).encrypted_password,
            post_order: params[:post_order]
        }
      else 
        return {
          email: user.email,
          password: User.new(password: params[:user][:password]).encrypted_password,
      }
      end
  end

  def deserialize(id,user)
      return { 
      id: id, 
      email: user.email, 
      password: user.password
      }
  end

  def comparePasswords(password, encryptedPassword)
    decryptPass = Devise::Encryptable::Encryptors::Aes256.decrypt(encryptedPassword, Devise.pepper)
    return password == decryptPass
  end


  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end


end
