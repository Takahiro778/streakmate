module FlashHelper
  def flash_ui_for(type)
    key = type.to_s
    key = "success" if %w[notice success].include?(key)
    key = "error"   if %w[alert error].include?(key)
    key = "warning" if key == "warning"
    key = "info"    if key == "info"

    case key
    when "success"
      { bg: "bg-emerald-50", border: "border-emerald-200", text: "text-emerald-900", icon_color: "text-emerald-600" }
    when "warning"
      { bg: "bg-amber-50",   border: "border-amber-200",   text: "text-amber-900",   icon_color: "text-amber-600" }
    when "error"
      { bg: "bg-rose-50",    border: "border-rose-200",    text: "text-rose-900",    icon_color: "text-rose-600" }
    else # info
      { bg: "bg-sky-50",     border: "border-sky-200",     text: "text-sky-900",     icon_color: "text-sky-600" }
    end
  end
end
