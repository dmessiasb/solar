class PostsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :prepare_for_pagination

  load_and_authorize_resource :except => [:index, :create]

  # GET /discussions/1/posts
  # GET /discussions/1/posts/20120217/news/asc/order/10/limit
  # GET /discussions/1/posts/20120217/history/asc/order/10/limit
  def index
    authorize! :index, Post

    @posts, count = [], []
    begin
      @discussion = Discussion.find(params[:discussion_id])

      if @can_see = @discussion.user_can_see?(current_user.id)
        @can_interact = @discussion.user_can_interact?(current_user.id)
        p = params.select { |k, v| ['date', 'type', 'order', 'limit', 'display_mode', 'page'].include?(k) }
        p['page'] ||= @current_page

        @display_mode = p['display_mode'] ||= 'tree'
        @posts = @discussion.posts(p)

        # verificar se eh json ou xml para fazer isso
        period = (@posts.empty?) ? [p['date'], p['date']] : [@posts.first.updated_at, @posts.last.updated_at].sort
        count = @discussion.count_posts_after_and_before_period(period)
      end
    rescue
    end

    respond_to do |format|
      format.html # list.html.erb
      format.xml  { render :xml => count + @posts }
      format.json  { render :json => count + @posts }
    end
  end

  # POST /discussions/:id/posts
  # POST /discussions/:id/posts.xml
  def create
    authorize! :create, Post

    @post = Post.new(params[:discussion_post])
    allocation_tag_id = Discussion.find(@post.discussion_id).allocation_tag_id

    @post.user_id = current_user.id
    @post.profile_id = current_user.profiles_with_access_on('create', 'posts', allocation_tag_id, only_id = true).first
    @post.level = @post.parent.level.to_i + 1 unless @post.parent_id.nil?

    respond_to do |format|
      if @post.save
        format.html { redirect_to(discussion_posts_path(Discussion.find(params[:discussion_id])), :notice => t(:discussion_post_created)) }
        format.xml  { render :xml => @post, :status => :created }
        format.json  { render :json => {:result => 1, :post_id => @post.id}, :status => :created }
      else
        format.html { render :json => {:result => 0} }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        format.json  { render :json => {:result => 0}, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /discussions/:id/posts/1
  # PUT /discussions/:id/posts/1.xml
  def update
    respond_to do |format|
      if @post.update_attributes(params[:discussion_post])
        format.html { redirect_to(discussion_posts_path(@post.discussion), :notice => t(:discussion_post_updated)) }
        format.xml  { head :ok }
        format.json  { head :ok }
      else
        format.html { redirect_to(discussion_posts_path(@post.discussion), :alert => t(:discussion_post_not_updated)) }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        format.json  { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post.files.each do |file|
      file.delete
      File.delete(file.attachment.path) if File.exist?(file.attachment.path)
    end

    @post.destroy

    respond_to do |format|
      format.html { render :json => {:result => :ok} }
      format.xml  { head :ok }
      format.json  { render :json => {:result => :ok} }
    end
  end

end