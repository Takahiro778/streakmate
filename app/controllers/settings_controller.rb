class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_setting

  def show
  end

  def update
    # トグルUIのみ → 23:00固定で保存、TZも保存
    @setting.assign_attributes(
      bedtime_enabled: ActiveModel::Type::Boolean.new.cast(params.dig(:setting, :bedtime_enabled)),
      bedtime_time: Time.zone.parse("23:00"),
      time_zone: Time.zone.name
    )

    if @setting.save
      respond_to do |format|
        format.html { redirect_to setting_path, notice: "設定を保存しました。" }
        format.turbo_stream
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_setting
    @setting = current_user.setting || current_user.create_setting!
  end
end
