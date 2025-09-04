class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_setting

  def show; end

  def update
    attrs = normalized_setting_params

    # 既存値が空で、今回も時刻未指定なら 23:00 を初期値で補完
    if @setting.bedtime_time.blank? && !attrs.key?(:bedtime_time)
      attrs[:bedtime_time] = Time.zone.parse("23:00")
    end

    @setting.assign_attributes(attrs)

    if @setting.save
      respond_to do |format|
        format.html        { redirect_to setting_path, notice: "設定を保存しました。" }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html        { render :show, status: :unprocessable_entity }
        format.turbo_stream { render :show, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_setting
    # 既存ユーザーでも確実に設定を持つ
    @setting = current_user.setting || current_user.ensure_setting!
  end

  # --- params ---

  # strong params（未送信キーは触らない）
  def setting_params
    params.fetch(:setting, {}).permit(:bedtime_enabled, :bedtime_time, :time_zone)
  end

  # 受け取った文字列を Ruby 値に正規化して返す
  def normalized_setting_params
    raw = setting_params.to_h.compact

    out = {}

    # bedtime_enabled: "0"/"1" or "true"/"false" を確実に boolean 化
    if raw.key?("bedtime_enabled")
      out[:bedtime_enabled] =
        ActiveModel::Type::Boolean.new.cast(raw["bedtime_enabled"])
    end

    # bedtime_time: "HH:MM" を TimeWithZone にパース（失敗 or 空なら上書きしない）
    if raw["bedtime_time"].present?
      parsed = safe_parse_time(raw["bedtime_time"])
      out[:bedtime_time] = parsed if parsed.present?
    end

    # time_zone: 空や nil は上書きしない
    if raw["time_zone"].present?
      out[:time_zone] = raw["time_zone"]
    end

    out
  end

  # "23:00" 等を現在の Time.zone でパース。失敗時は nil を返す
  def safe_parse_time(hhmm)
    Time.zone.parse(hhmm)
  rescue ArgumentError, TypeError
    nil
  end
end
