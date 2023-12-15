class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  # condition for before_action. If we visit the site and the preferences are set, we update the prefereces
  before_action :update_preferences, if: -> { params[:preference].present? }

  # GET /posts or /posts.json
  def index
    # @posts = Post.all
    @posts = Post.order(created_at: preference_order)
    @default_selected = get_preference(:post_order)
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
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
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
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body)
    end


    def preference_order      
      preference = get_preference(:post_order)
      preference == "oldest" ? :asc : :desc
    end

    def get_preference(key)
      if user_signed_in? && !key.nil?
        puts ":post_order = #{key}"
        if current_user.preference          
          preference = current_user.preference[key]
          puts "posts_controller signed in user get_preference(#{key}) current_user.preference[#{key}] = #{preference}" 
          return current_user.preference[key] 
        else 
          # debugger
          preferences = { post_order: "oldest", user_id: current_user.id }
          current_user_preference = Preference.create(**preferences)
          current_user_preference.save          
          return current_user.preference[key]
        end
      end
      
      if cookies[key].present?
        puts "posts_controller not signed in user get_preference(#{key}) cookies[key]  = #{cookies[key]}" 
        return cookies[key] 
      end
      puts "posts_controller has not signed in current_user.preference and has not cookies get_preference(#{key}) and use default preferences as =  oldiest"
      return "oldiest"
    end

    def update_preferences
      preferences = { post_order: params[:preference] }      
      
      if user_signed_in?
        Preference.update_user_preferences( current_user, preferences)
        puts "posts_controller Preference.update_user_preferences = #{preferences}"
      else
        GuestPreferenceService.update_guest_preferences( cookies, preferences)
        puts "posts_controller GuestPreferenceService.update_user_preferences = #{cookies} #{preferences}"
      end
    
    end

end
