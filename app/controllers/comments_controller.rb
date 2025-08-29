class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_log
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :authorize_destroy!, only: [:destroy]
  before_action :authorize_edit!,    only: [:edit, :update]

  def create
    @comment = @log.comments.build(comment_params.merge(user: current_user))
    if @comment.save
      @log.reload
      respond_to do |f|
        f.turbo_stream
        f.html { redirect_back fallback_location: timeline_index_path, notice: "コメントを投稿しました" }
      end
    else
      respond_to do |f|
        f.turbo_stream { render :create, status: :unprocessable_entity }
        f.html { redirect_back fallback_location: timeline_index_path, alert: @comment.errors.full_messages.first }
      end
    end
  end

  def edit
    respond_to do |f|
      f.turbo_stream
      f.html { redirect_back fallback_location: timeline_index_path }
    end
  end

  def update
    if @comment.update(comment_params)
      respond_to do |f|
        f.turbo_stream
        f.html { redirect_back fallback_location: timeline_index_path, notice: "コメントを更新しました" }
      end
    else
      respond_to do |f|
        f.turbo_stream { render :edit, status: :unprocessable_entity }
        f.html { redirect_back fallback_location: timeline_index_path, alert: @comment.errors.full_messages.first }
      end
    end
  end

  def destroy
    @comment.destroy
    respond_to do |f|
      f.turbo_stream
      f.html { redirect_back fallback_location: timeline_index_path, notice: "コメントを削除しました" }
    end
  end

  private

  def set_log
    # 可視性を尊重（非公開ログ等にコメントできない）
    @log = Log.visible_to(current_user).find(params[:log_id])
  end

  def set_comment
    @comment = @log.comments.find(params[:id])
  end

  def authorize_destroy!
    # 削除は「コメント本人」or「ログ投稿者」
    head :forbidden unless @comment.user_id == current_user.id || @log.user_id == current_user.id
  end

  def authorize_edit!
    head :forbidden unless @comment.user_id == current_user.id
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
