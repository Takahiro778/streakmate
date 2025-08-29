class CheersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_log
  before_action :forbid_self_cheer!

  def create
    @cheer = current_user.cheers.build(log: @log)

    if @cheer.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: @log, notice: "応援しました" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@log, :cheer), partial: "cheers/button", locals: { log: @log }) }
        format.html { redirect_back fallback_location: @log, alert: @cheer.errors.full_messages.first }
      end
    end
  end

  def destroy
    @cheer = current_user.cheers.find_by!(log: @log)
    @cheer.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: @log, notice: "応援を取り消しました" }
    end
  end

  private

  def set_log
    @log = Log.find(params[:log_id])
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
