module UiHelper
  # name:   "home" など Heroicons 名
  # variant: :outline / :solid
  # size:   Tailwind サイズクラス
  # classes: 追加クラス
  # **attrs: 任意のHTML属性（:"aria-hidden", aria: { hidden: true }, id:, data: など）
  def icon(name, variant: :outline, size: "w-5 h-5", classes: "", **attrs)
    # "aria-hidden" を受け取った場合は aria: { hidden: true/false } に正規化する
    aria_hidden_raw = attrs.delete(:"aria-hidden")
    options = { class: "#{size} #{classes}" }

    unless aria_hidden_raw.nil?
      hidden = (aria_hidden_raw == true || aria_hidden_raw == "true" || aria_hidden_raw == 1 || aria_hidden_raw == "1")
      options[:aria] = (options[:aria] || {}).merge(hidden: hidden)
    end

    # 残りの属性をそのまま options に合流（id, data, aria, title など）
    options.merge!(attrs) unless attrs.empty?

    if respond_to?(:heroicon)
      heroicon name, variant: variant, options: options
    else
      # フォールバック（heroicon が未ロードでも落ちないように）
      content_tag :svg, "", xmlns: "http://www.w3.org/2000/svg",
                           viewBox: "0 0 24 24",
                           **options
    end
  end
end
