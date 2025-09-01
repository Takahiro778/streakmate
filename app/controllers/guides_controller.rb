class GuidesController < ApplicationController
  # /guides/:id  (例: /guides/relax, /guides/sleep)
  def show
    @category = params[:id].in?(%w[relax sleep]) ? params[:id] : "relax"
    # ビュー側で @category を使ってランチャーに渡す想定
  end
end
