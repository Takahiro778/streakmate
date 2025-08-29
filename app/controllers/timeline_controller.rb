class TimelineController < ApplicationController
  before_action :authenticate_user!

  def index
    @scope = params[:scope].in?(%w[all following]) ? params[:scope] : "all"
    base = Log.includes(user: :profile).recent

    @logs =
      if @scope == "following"
        base.timeline_for_following(current_user)
      else
        base.visible_to(current_user)
      end

    @logs = @logs.page(params[:page]).per(20)
  end
end
