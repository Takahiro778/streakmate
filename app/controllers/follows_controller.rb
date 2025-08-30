class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :forbid_self_follow!

  def create
    current_user.active_follows.create_or_find_by!(followed: @user)
    @user.reload
    respond_to do |f|
      f.turbo_stream
      f.html { redirect_back fallback_location: root_path, notice: "フォローしました" }
    end
  rescue ActiveRecord::RecordNotUnique
    @user.reload
    respond_to(&:turbo_stream)
  end

  def destroy
    current_user.active_follows.destroy_by(followed: @user)  # counter_cache更新のためdestroy系
    @user.reload
    respond_to do |f|
      f.turbo_stream
      f.html { redirect_back fallback_location: root_path, notice: "フォローを解除しました" }
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def forbid_self_follow!
    if @user.id == current_user.id
      respond_to do |f|
        f.turbo_stream { head :forbidden }
        f.html { redirect_back fallback_location: root_path, alert: "自分はフォローできません" }
      end
    end
  end
end
