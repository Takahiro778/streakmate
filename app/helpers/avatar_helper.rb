module AvatarHelper
  # ユーザーのアイコンを表示するヘルパー
  # - size: 表示サイズ(px)
  # - class / cls: 追加のCSSクラス（どちらでも可）
  # - その他のキーワード引数は image_tag にそのまま渡す
  def avatar_for(user, size: 32, **kwargs)
    # class / cls の同義ハンドリング
    extra = [kwargs.delete(:class), kwargs.delete(:cls)].compact.join(" ")
    base  = "rounded-full object-cover"
    css   = [base, extra].reject(&:blank?).join(" ")

    if user&.profile&.avatar&.attached?
      image_tag(
        user.profile.avatar.variant(resize_to_fill: [size, size]).processed,
        { width: size, height: size, alt: "avatar", class: css }.merge(kwargs)
      )
    else
      # ダミー（assets の svg/png 等）
      image_tag(
        "dummy_icon.svg",
        { width: size, height: size, alt: "avatar", class: css }.merge(kwargs)
      )
    end
  end
end
