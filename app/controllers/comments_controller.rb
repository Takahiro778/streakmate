class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_log
  before_action :set_comment, only: [:edit, :update, :destroy]

  def create
    @comment = @log.comments.build(comment_params.merge(user: current_user))

    if @comment.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            # 直近を上に積むなら prepend、下に並べるなら append
            turbo_stream.prepend(
              helpers.dom_id(@log, :comments),
              partial: "comments/comment",
              locals: { comment: @comment }
            ),
            # 新規フォームを空に戻す
            turbo_stream.replace(
              "new_comment",
              partial: "comments/form",
              locals: { log: @log, comment: Comment.new }
            )
          ]
        end
        format.html { redirect_to log_path(@log), notice: "コメントを追加しました" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_comment",
            partial: "comments/form",
            locals: { log: @log, comment: @comment }
          ), status: :unprocessable_entity
        end
        format.html { render "logs/show", status: :unprocessable_entity }
      end
    end
  end

  def edit
    render partial: "comments/edit_form", locals: { log: @log, comment: @comment }
  end

  def update
    if @comment.update(comment_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            helpers.dom_id(@comment),
            partial: "comments/comment",
            locals: { comment: @comment }
          )
        end
        format.html { redirect_to log_path(@log), notice: "コメントを更新しました" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render partial: "comments/edit_form",
                 locals: { log: @log, comment: @comment },
                 status: :unprocessable_entity
        end
        format.html { render "logs/show", status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(helpers.dom_id(@comment))
      end
      format.html { redirect_to log_path(@log), notice: "コメントを削除しました" }
    end
  end

  private

  def set_log
    @log = Log.find(params[:log_id])
  end

  def set_comment
    @comment = @log.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
