# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  def show
    @favorite_goals =
      Goal.joins(:favorites)                                   # 登録順で並べるために結合
          .where(favorites: { user_id: current_user.id })       # 自分がブクマしたものだけ
          .merge(Goal.visible_to(current_user))                 # 自分から見える目標のみ（public/ followers/ 自分）
          .where.not(user_id: current_user.id)                  # 自分の目標は除外（不要なら削除）
          .includes(:user, :category)                           # 表示用の先読み
          .order('favorites.created_at DESC')                   # 登録が新しい順
          .limit(50)
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
