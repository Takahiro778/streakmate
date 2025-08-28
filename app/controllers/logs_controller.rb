class LogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @log  = current_user.logs.build
    @logs = current_user.logs.order(created_at: :desc)
  end

  def create
    @log = current_user.logs.build(log_params)

    if @log.save
      respond_to do |format|
        # タイムライン先頭に反映（prepend）
        format.turbo_stream
        format.html { redirect_to logs_path, notice: "ログを追加しました" }
      end
    else
      # 失敗時もフォーム枠を Turbo Frame 経由で更新
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("logs_form", partial: "logs/form", locals: { log: @log }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  private

  def log_params
    params.require(:log).permit(:minutes, :category, :memo)
  end
end
