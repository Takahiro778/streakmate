class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_setting

  def show; end

  def update
    # チェックボックス未チェック時などで param が来ないケースに対応
    enabled_param = params.dig(:setting, :bedtime_enabled)
    enabled = enabled_param.nil? ? @setting.bedtime_enabled \
                                 : ActiveModel::Type::Boolean.new.cast(enabled_param)

    @setting.assign_attributes(
      bedtime_enabled: enabled,
      bedtime_time:    Time.zone.parse("23:00"),
      time_zone:       Time.zone.tzinfo.name
    )

    if @setting.save
      respond_to do |format|
        format.html { redirect_to setting_path, notice: "設定を保存しました。" }
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
end
