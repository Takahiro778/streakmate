class TimelineController < ApplicationController
  before_action :authenticate_user!, only: [:index], unless: -> { params[:tab] == "all" }
  # 未ログインでも全体は閲覧できる想定（要件に合わせて調整）

  def index
    @tab = params[:tab].presence_in(%w[all following]) || "all"

    base = Log.includes(user: :profile) # N+1対策
    @logs =
      if @tab == "following"
        base.timeline_for_following(current_user).recent.page(params[:page]).per(20)
      else
        base.visible_to(current_user).where(visibility: Log.visibilities[:public])
            .recent.page(params[:page]).per(20)
      end
  end
end
