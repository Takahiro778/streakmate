class CheersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_log # ← visible_to で可視性の範囲に限定
  before_action :forbid_self_cheer!

  def create
    # ユニーク制約競合にも強い書き方
    current_user.cheers.create_or_find_by!(log: @log)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: @log, notice: "応援しました" }
    end
  rescue ActiveRecord::RecordNotUnique
    # レース時の二重発行は成功扱いに寄せて再描画
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: @log, notice: "既に応援済みです" }
    end
  end

  def destroy
    current_user.cheers.where(log: @log).delete_all
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: @log, notice: "応援を取り消しました" }
    end
  end

  private

  def set_log
    # 不正アクセスで非可視ログが指定された場合に404
    @log = Log.visible_to(current_user).find(params[:log_id])
  end

  def forbid_self_cheer!
    if @log.user_id == current_user.id
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_back fallback_location: @log, alert: "自分の投稿には応援できません" }
      end
    end
  end
end
