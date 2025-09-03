class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  def show
    @favorite_goals =
      Goal.joins(:favorites)
          .where(favorites: { user_id: current_user.id })
          .merge(Goal.visible_to(current_user))
          .where.not(user_id: current_user.id)
          .includes(:user)
          .order('favorites.created_at DESC')
          .limit(50)
  end

  def edit; end

  def update
    # 削除チェックは「更新成功後」に実行して UX を担保
    remove_requested = (params.dig(:profile, :remove_avatar) == '1')

    if @profile.update(profile_params)
      @profile.avatar.purge_later if remove_requested && @profile.avatar.attached?
      redirect_to mypage_path, notice: 'プロフィールを更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveStorage::IntegrityError, ActiveSupport::MessageVerifier::InvalidSignature
    @profile.errors.add(:avatar, 'が不正なファイル形式か破損しています')
    render :edit, status: :unprocessable_entity
  end

  private

  def set_profile
    @profile = current_user.profile || current_user.build_profile
  end

  def profile_params
    params.require(:profile).permit(:display_name, :introduction, :avatar)
  end
end
