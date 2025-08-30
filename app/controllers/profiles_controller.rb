class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  def show
    @favorite_goals =
      current_user.favorited_goals
                  .where(visibility: Goal.visibilities[:public])   # 非公開は除外
                  .where.not(user_id: current_user.id)             # 自分の目標を除外（不要なら削除OK）
                  .includes(:user, :category)                      # N+1回避
                  .order(updated_at: :desc)                        # 新しい順
                  .limit(50)                                       # 表示数はお好みで
  end

  def edit; end

  def update
    if @profile.update(profile_params)
      redirect_to mypage_path, notice: 'プロフィールを更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = current_user.profile || current_user.build_profile
  end

  def profile_params
    params.require(:profile).permit(:display_name, :introduction, :avatar)
  end
end
