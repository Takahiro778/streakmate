class SuggestionsController < ApplicationController
  before_action :authenticate_user!

  def create
    category   = params[:category].presence  || "relax"
    @target_id = params[:target_id].presence || "suggestions"

    service = Guides::SuggestionService.new
    @suggestions = service.suggest(category: category)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path, notice: "提案を表示しました" }
      format.json { render json: @suggestions.map(&:to_h) }
    end
  end
end
