module ApplicationHelper
  def nav_active?(path) = current_page?(path)

  def nav_tab(label, path, icon)
    active = nav_active?(path)
    content_tag :a, href: path,
      class: [
        "flex flex-col items-center justify-center h-16", # 64px > 44px
        "text-xs", (active ? "text-black font-semibold" : "text-gray-500")
      ].join(" "),
      "aria-current": (active ? "page" : nil) do
        concat content_tag(:span, mobile_icon(icon, active), class: "text-xl")
        concat content_tag(:span, label, class: "mt-0.5")
      end
  end

  def mobile_icon(name, active=false)
    tone = active ? "currentColor" : "currentColor"
    case name
    when "home"     then "⌂"
    when "timeline" then "☰"
    when "guide"    then "✦"
    when "me"       then "☺"
    else "•"
    end
  end
end
