class LogsController < ApplicationController
  before_action :authenticate_user!

  # Pundit の検証フック
  after_action :verify_authorized,    except: [:index]
  after_action :verify_policy_scoped, only:   [:index]

  def index
    @log = current_user.logs.build

    # ✅ 自分のダッシュボード用でも policy_scope を必ず経由
    base_scope = Log.where(user_id: current_user.id)
    @logs = policy_scope(base_scope)
              .includes(:cheers, :comments)
              .order(created_at: :desc)

    # ✅ ダッシュボード用メトリクス
    @streak_days    = current_user.streak_days
    @weekly_minutes = current_user.weekly_minutes
  end

  def show
    # 閲覧時は認可チェック（public / followers / private を Pundit 側で判定）
    @log = Log.includes(:cheers, :comments).find(params[:id])
    authorize @log  # => LogPolicy#show?
  end

  def create
    @log = current_user.logs.build(log_params)
    authorize @log  # => LogPolicy#create?

    if @log.save
      # ✅ 作成後の最新値（将来 turbo_stream 差し替えで使用）
      @streak_days    = current_user.streak_days
      @weekly_minutes = current_user.weekly_minutes

      respond_to do |format|
        format.turbo_stream  # タイムライン先頭に反映（prepend）
        format.html { redirect_to logs_path, notice: "ログを追加しました" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "logs_form",
            partial: "logs/form",
            locals: { log: @log }
          )
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  private

  def log_params
    params.require(:log).permit(:minutes, :category, :memo, :visibility)
  end
end
