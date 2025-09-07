module UiHelper
  def icon(name, variant: :outline, size: "w-5 h-5", classes: "")
    heroicon name, variant: variant, options: { class: "#{size} #{classes}" }
  end
end
