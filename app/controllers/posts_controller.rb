class PostsController < BaseIndexController
  before_action :find_post, only: [:edit, :update, :show, :destroy, :collect, :discollect]
  skip_before_action :authenticate_user!, only: :index

  helper_method :sort_column, :sort_direction

  def index
    published = Post.all.where(status: "published")
    @posts = published.order("#{sort_column} #{sort_direction}").page(params[:page]).per(20)
    @categories = Category.all
  end

  def show
    @categories = @post.folders
    @comment = Comment.new
    @comments = @post.comments.page(params[:page]).per(20)
    
    @view = @post.views.build(user: current_user)
    @view.save
  end

  def new
    @post = current_user.posts.build
    @all_categories = Category.all
    @folder = @post.folders.build
  end

  def create
    @post = current_user.posts.build(post_params)
    
    params[:categories][:id].each do |category|
      if !category.empty?
        @post.folders.build(:category_id => category)
      end
    end

    if params[:commit] == 'Save as Draft'
      @post.status = "draft"
      if @post.save
        redirect_to drafts_user_path(current_user), notice: "There is your drafts"
      else
        render 'new'
      end
    else
      @post.status = "published"
      if @post.save
        redirect_to @post, notice: "You Created a Post!"
      else
        render 'new'
      end
    end
  end

  def edit
    @all_categories = Category.all
    @folder = @post.folders.build
  end

  def update
    folders = Folder.where(post: @post)
    folders.destroy_all

    params[:categories][:id].each do |category|
      if !category.empty?
        @post.folders.build(:category_id => category)
      end
    end

    if params[:commit] == 'Save as Draft'
      @post.status = "draft"
      if @post.update(post_params)
        redirect_to drafts_user_path(current_user), notice: "You updated a draft."
      else
        render 'edit'
      end
    else
      @post.status = "published"
      if @post.update(post_params)
        redirect_to @post, notice: "You Updated this Post!"
      else
        render 'edit'
      end
    end
  end

  def destroy
    @post.destroy
    redirect_to root_path, alert: "You Deleted this Post!!!"
  end

  def feeds
    @users_size = User.all.size
    @posts_size = Post.all.size
    @comments_size = Comment.all.size
    @chatter_users = User.all.order(comments_count: :desc).limit(10)
    @popular_posts = Post.all.order(comments_count: :desc).limit(10)
  end

  def collect
    @post.collections.create!(user: current_user)

    respond_to do |format|
      format.html{redirect_back(fallback_location: root_path)}
      format.js
    end
  end
  
  def discollect
    collections = Collection.where(post: @post, user: current_user)
    collections.destroy_all

    respond_to do |format|
      format.html{ redirect_back(fallback_location: root_path) }
      format.js { render 'collect' }
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :image, :privacy)
  end

  def find_post
    @post = Post.find(params[:id])
  end

end
