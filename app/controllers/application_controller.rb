class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  # ✅ ログイン後はマイページへ
  def after_sign_in_path_for(_resource)
    mypage_path
  end

  # （任意）サインアップ直後もマイページへ
  def after_sign_up_path_for(_resource)
    mypage_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,        keys: [:nickname])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname])
  end

  private

  # 認可NG時は存在を匂わせない 404 に寄せる
  def user_not_authorized
    respond_to do |format|
      format.html do
        render file: Rails.root.join("public/404.html"),
               status: :not_found,
               layout: false
      end
      format.json { head :not_found }
      format.turbo_stream do
        render file: Rails.root.join("public/404.html"),
               status: :not_found,
               layout: false
      end
      format.any  { head :not_found }
    end
  end
end
