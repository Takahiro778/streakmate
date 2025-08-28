class LogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @log  = current_user.logs.build
    @logs = current_user.logs.order(created_at: :desc)

    # ✅ ダッシュボード用
    @streak_days    = current_user.streak_days
    @weekly_minutes = current_user.weekly_minutes
  end

  def create
    @log = current_user.logs.build(log_params)

    if @log.save
      # ✅ 作成後の最新値（将来 dashboard を turbo_stream で差し替える時に利用）
      @streak_days    = current_user.streak_days
      @weekly_minutes = current_user.weekly_minutes

      respond_to do |format|
        # タイムライン先頭に反映（prepend）
        format.turbo_stream
        format.html { redirect_to logs_path, notice: "ログを追加しました" }
      end
    else
      # 失敗時もフォーム枠を Turbo Frame 経由で更新
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "logs_form",
            partial: "logs/form",
            locals: { log: @log }
          )
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  private

  def log_params
    params.require(:log).permit(:minutes, :category, :memo)
  end
end
