class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_setting

  def update
    attrs = setting_params.to_h

    # boolean 正規化
    attrs[:bedtime_enabled] =
      ActiveModel::Type::Boolean.new.cast(attrs[:bedtime_enabled])

    # 時刻パース（"HH:MM"）。空なら既存値を保持、未設定なら 23:00 を初期化
    if attrs[:bedtime_time].present?
      begin
        attrs[:bedtime_time] = Time.zone.parse(attrs[:bedtime_time])
      rescue ArgumentError, TypeError
        attrs.delete(:bedtime_time)
      end
    elsif @setting.bedtime_time.blank?
      attrs[:bedtime_time] = Time.zone.parse("23:00")
    end

    if @setting.update(attrs)
      # 保存直後の表示ブロックで必ず最新値を使えるよう More に戻す
      redirect_to more_path, notice: "設定を保存しました。"
    else
      redirect_to more_path, alert: "設定の保存に失敗しました。"
    end
  end

  private

  def set_setting
    @setting = current_user.setting || current_user.ensure_setting!
  end

  def setting_params
    params.fetch(:setting, {}).permit(:bedtime_enabled, :bedtime_time, :time_zone)
  end
end
