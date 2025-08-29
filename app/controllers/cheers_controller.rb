# app/controllers/cheers_controller.rb
class CheersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_log
  before_action :forbid_self_cheer!

  def create
    current_user.cheers.create_or_find_by!(log: @log)
    @log.reload  # ← ここがポイント（最新の cheers_count を反映）
    respond_to do |f|
      f.turbo_stream
      f.html { redirect_back fallback_location: @log, notice: "応援しました" }
    end
  rescue ActiveRecord::RecordNotUnique
    @log.reload
    respond_to do |f|
      f.turbo_stream
      f.html { redirect_back fallback_location: @log, notice: "既に応援済みです" }
    end
  end

  def destroy
    current_user.cheers.destroy_by(log: @log)  # counter_cache が減る
    @log.reload  # ← 最新値に更新
    respond_to do |f|
      f.turbo_stream
      f.html { redirect_back fallback_location: @log, notice: "応援を取り消しました" }
    end
  end

  private

  def set_log
    @log = Log.visible_to(current_user).find(params[:log_id])
  end

  def forbid_self_cheer!
    if @log.user_id == current_user.id
      respond_to do |f|
        f.turbo_stream { head :forbidden }
        f.html { redirect_back fallback_location: @log, alert: "自分の投稿には応援できません" }
      end
    end
  end
end