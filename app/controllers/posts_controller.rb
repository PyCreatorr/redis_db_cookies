class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  # condition for before_action. If we visit the site and the preferences are set, we update the prefereces
  before_action :update_preferences, if: -> { params[:preference].present? }

  # GET /posts or /posts.json
  def index
    # @posts = Post.all

    offset = 0
    count = 100
    order = 'DESC'

    @redis = RedisService.set_redis()

    # product:*->id

    key_pattern = 'posts#*:'

    # RedisPreferenceService.postsKey('*')

    results = @redis.sort(RedisPreferenceService.postsAllKey(), 
          get: [
              '#', 
              'posts#*->title', 
              'posts#*->body',
              'posts#*->created_at',
              'posts#*->updated_at'
              #`#{key_pattern}->updated_at`
          ],
          # BY: 'no_sort',
          by: 'posts#*->created_at',
          order: preference_order,
          limit: [ offset, count ]
      )

      #direction: preference_order

    @redis.close()

    # Parsing the array of array into 5 fields

  #   while(results.length){        

  #     const [id, name, views, endingAt, imageUrl, price,  ...rest] = results;
  #     //console.log("rest=", rest);
      
  #     const item = deserialize(id, {name, views, endingAt, imageUrl, price});
  #     items.push(item);

  #     //console.log("itemm=", item);

  #     results = rest;
  # }

  sec=''
  sec2 = ''
  posts = []

  results.each do |arr|
    sec = (arr[3].to_f / 1000).to_s
    sec2 = (arr[4].to_f / 1000).to_s

    hashParams = {id: arr[0].to_i, title: arr[1], body: arr[2], created_at: DateTime.strptime(sec, '%s'), updated_at: DateTime.strptime(sec2, '%s') }
    post = Post.new(hashParams)
    posts.append(post)
  end

  @posts = posts

  @default_selected = get_preference(:post_order) if !user_signed_in?


    # debugger



    # // SORT the items by view score
    # let results: any = await client.sort(itemsByViewsKey(), {
    #     GET: [
    #         '#', 
    #         `${itemsKey('*')}->name`, 
    #         `${itemsKey('*')}->views`,
    #         `${itemsKey('*')}->endingAt`,
    #         `${itemsKey('*')}->imageUrl`,
    #         `${itemsKey('*')}->price`
    #     ],
    #     //BY: 'no_sort',
    #     BY: `${itemsKey('*')}->views`,
    #     DIRECTION: order,
    #     LIMIT: {offset, count }
    # });

    #@redis.zAdd(RedisPreferenceService.postsAllKey(), serialized[:created_at], id)

    #@posts = Post.order(created_at: preference_order)



    
    # debugger
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit


  end

  # POST /posts or /posts.json
  def create
    

    @redis = RedisService.set_redis()
    id = Random.new.rand(100000..10000000)
    params[:id] = id

    serialized = serialize(params)

    result = @redis.hSet(RedisPreferenceService.postsKey(id), serialized)

    # Create sorted set with all posts ids - score and the created_at:
    @redis.zAdd(RedisPreferenceService.postsAllKey(), serialized[:created_at], id)

    # Create sorted set with the usernames and ids, converted into the number
    # await client.zAdd(usernamesKey(), {score: parseInt(id, 16), value: attrs.username});
    # Add itemId and score 0 to the sirted set with the prices.
    # client.zAdd(itemsByPriceKey(), {value: id, score: 0})

    @redis.close()

    
    @post = Post.new(deserialize(params))
    puts "serialize(params) = #{serialize(params)}"

    # debugger

    respond_to do |format|
      if @post.present?
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        #format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        #format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|

      @redis = RedisService.set_redis()

      result = @redis.hSet(RedisPreferenceService.postsKey(id), serialize(params))
      @redis.close()

      if @post.update(post_params)
        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def serialize(params)
      return {
          #id: params[:id],
          title: params[:post][:title],
          body: params[:post][:body],
          created_at: Time.current.strftime('%s%3N'),
          updated_at: Time.current.strftime('%s%3N')
        }
    end

    def deserialize(params)
      sec = (params[:post][:created_at].to_f / 1000).to_s
      se2 = (params[:post][:updated_at].to_f / 1000).to_s

      return {
          id: params[:id],
          title: params[:post][:title],
          body: params[:post][:body],
          created_at: DateTime.strptime(sec, '%s'),
          updated_at: DateTime.strptime(sec, '%s')
        }
    end




    def set_post
      # @post = Post.find(params[:id])
      @redis = RedisService.set_redis()

      postHashes = @redis.hGetAll(RedisPreferenceService.postsKey(params[:id]))
      @redis.close()
      

      sec = (postHashes[5].to_f / 1000).to_s
      sec2 = (postHashes[7].to_f / 1000).to_s

      hashParams = {id: params[:id], title: postHashes[1], body: postHashes[3], created_at: DateTime.strptime(sec, '%s'), updated_at: DateTime.strptime(sec2, '%s') }
      @post = Post.new(hashParams)

      
      #user=User.new(id: id, email: userHashes[1], password: userHashes[3], encrypted_password: userHashes[3])
      
      # debugger

    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body)
    end


    def preference_order      
      preference = get_preference(:post_order)
      # preference == "oldest" ? :asc : :desc
      preference == "oldest" ? 'ASC' : 'DESC'
    end

    def get_preference(key)

     #debugger

      # if user logged in and (1. have no guests cookies, else 2. save preference into db with oldest and userId)
      if user_signed_in? && !key.nil?
        puts ":post_order = #{key}"
        if current_user.preference          
          #preference = current_user.preference[key]

          
          #puts "posts_controller signed in user get_preference(#{key}) current_user.preference[#{key}] = #{preference}" 
          return { post_order: current_user.preference[key] , user_id: current_user.id }
        else 
          # debugger
          preferences = { post_order: "oldest", user_id: current_user.id }

          # current_user_preference = Preference.create(**preferences)
          # current_user_preference.save   
          return { post_order: "oldest", user_id: current_user.id }     
          #return current_user.preference[key]
        end
      end

      

      # get cookie from the redis db
      # if RedisPreferenceService.getSession(id).present?
      #   puts "posts_controller guest RedisPreferenceService.getSession(#{id}) = #{RedisPreferenceService.getSession(id)}"
      
      # else 
      #   preferences = { post_order: "oldest" }        
      #   puts "posts_controller guest RedisPreferenceService.saveSession(#{id}) = #{RedisPreferenceService.getSession(id)}"
      #   RedisPreferenceService.saveSession(preferences)
      # end
      
      # If cookies exists - return guest cookies
      if cookies[key].present?
        puts "posts_controller not signed in user get_preference(#{key}) cookies[key]  = #{cookies[key]}"
        return cookies[key] 
      end

      # If guest have no cookies at all - return default preference - oldest
      puts "posts_controller has not signed in current_user.preference and has not cookies get_preference(#{key}) and use default preferences as =  oldest"
      return "oldest"
    end

    def update_preferences
      preferences = { post_order: params[:preference] }   
      
      puts "SESSON = #{session}" 
      #debugger
      
      if user_signed_in?

        # @redis = RedisService.set_redis()
        # @redis.hSet(RedisPreferenceService.usersKey(current_user.id), preferences)
        # @redis.close()

        Preference.update_user_preferences( current_user, preferences)
        puts "posts_controller Preference.update_user_preferences = #{preferences}"
      else

        GuestPreferenceService.update_guest_preferences(cookies, preferences)
        puts "posts_controller GuestPreferenceService.update_user_preferences = #{cookies} #{preferences}"
      end
    
    end

end
