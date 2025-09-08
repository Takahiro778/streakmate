class LogsController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized,    except: [:index]
  after_action :verify_policy_scoped, only:   [:index]

  def index
    @log = current_user.logs.build
    @filter = params[:f].presence_in(%w[today week all]) || "all"

    base_scope = Log.where(user_id: current_user.id)
    @logs = policy_scope(base_scope)
              .filtered_by(@filter)
              .includes(:user, :cheers, :comments)
              .order(created_at: :desc)
              .page(params[:page]).per(20)

    @streak_days    = current_user.streak_days
    @weekly_minutes = current_user.weekly_minutes
  end

  def show
    @log = Log.includes(
      :user,
      :cheers,
      comments: { user: { profile: [:avatar_attachment, :avatar_blob] } }
    ).find(params[:id])

    authorize @log

    # 一覧側でソートが必要なら controller で明示
    @comments = @log.comments.order(:created_at)
  end

  def create
    @log = current_user.logs.build(log_params)
    authorize @log

    if @log.save
      @streak_days    = current_user.streak_days
      @weekly_minutes = current_user.weekly_minutes
      respond_to do |format|
        format.turbo_stream
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

  # ✅ 追加：ログ削除（フラッシュ付で一覧へ）
  def destroy
    @log = Log.find(params[:id])
    authorize @log
    if @log.user_id == current_user.id
      @log.destroy!
      redirect_to logs_path, notice: "ログを削除しました"
    else
      redirect_to @log, alert: "削除できるのは自分のログだけです"
    end
  end

  private

  def log_params
    params.require(:log).permit(:minutes, :category, :memo, :visibility)
  end
end
