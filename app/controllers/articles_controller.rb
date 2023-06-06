class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show update destroy ]
  before_action :authenticate_user!, only: %i[edit new create update destroy]

  # GET /articles
  def index
    @articles = Article.where(private: false)

    if user_signed_in?
      @articles = @articles.or(current_user.articles.where(private: true))
    end

    @articles = @articles.order(created_at: :desc)
    render json: @articles
  end

  # GET /articles/1
  def show
    unless current_user == @article.user
      render json: { error: 'You are not authorized to view this article.' }, status: :unauthorized
      return
    end
    render json: @article
  end

  # POST /articles
  def create
    @article = current_user.articles.build(article_params)

    if @article.save
      render json: @article, status: :created, location: @article
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /articles/1
  def update
    unless current_user == @article.user
      render json: { error: 'You are not authorized to update this article.' }, status: :unauthorized
      return
    end

    if @article.update(article_params)
      render json: @article, status: :ok
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # DELETE /articles/1
  def destroy
    unless current_user == @article.user
      render json: { error: 'You are not authorized to delete this article.' }, status: :unauthorized
      return
    end

    @article.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:title, :content, :private)
    end
end
