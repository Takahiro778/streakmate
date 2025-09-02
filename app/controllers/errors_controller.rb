class ErrorsController < ApplicationController
  skip_before_action :authenticate_user! rescue nil # 認証がある場合の保険
  layout "application"  # ブランド準拠で表示

  def not_found
    respond_to do |format|
      format.html { render :not_found, status: :not_found }
      format.json { head :not_found }
    end
  end

  def internal_server_error
    # 500 の詳細は出さない（ログには出る）
    respond_to do |format|
      format.html { render :internal_server_error, status: :internal_server_error }
      format.json { head :internal_server_error }
    end
  end
end
