class HomeController < ApplicationController
  # 未定義でも落とさない
  skip_before_action :authenticate_user!, raise: false
  def show; end
end
