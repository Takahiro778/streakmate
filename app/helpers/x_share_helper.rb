module XShareHelper
  INTENT_BASE = "https://x.com/intent/post".freeze

  # 明示的に「公開」のものだけ true にする（誤公開防止）
  def public_resource?(resource)
    return false if resource.blank?

    if resource.respond_to?(:visibility)
      return resource.visibility.to_s == "public"
    end

    return !!resource.public?   if resource.respond_to?(:public?)
    return false                if resource.respond_to?(:private?) && resource.private?

    return true if resource.is_a?(Log)
    
    # 公開フラグが無い型はデフォルトで非公開扱い
    false
  end

  # 共有可能な絶対URL（非公開は nil）
  def shareable_url_for(resource)
    return unless public_resource?(resource)

    case resource
    when Log
      # ログ詳細ページが無い想定 → タイムラインの該当カードへ
      timeline_index_url(anchor: "log-#{resource.id}")
    when Goal
      goal_url(resource)
    else
      nil
    end
  end

  # ex) https://twitter.com/intent/tweet?text=...&url=...&hashtags=foo,bar
  def x_intent_url(text:, url:, hashtags: [], via: nil)
    # 個人情報混入・改行・過剰長を抑制
    safe_text = strip_tags(text.to_s).gsub(/\s+/, " ").strip
    safe_text = safe_text.truncate(120) # URL/ハッシュタグ分の余白を確保

    tags = Array(hashtags).map { |h| h.to_s.delete("#,").strip }.reject(&:blank?)

    q = { text: safe_text, url: url }
    q[:hashtags] = tags.join(",") if tags.any?
    q[:via]      = via.to_s if via.present?

    "#{INTENT_BASE}?#{q.to_query}"
  end

  def default_share_text(resource)
    case resource
    when Log   then "今日もコツコツ記録中"
    when Goal  then "目標を公開しました"
    else            "StreakMateからシェア"
    end
  end

  # できあがった intent へのリンク（新規タブで開く）
  # 非公開はボタン自体を出さない
  def x_share_link_to(resource, text: nil, hashtags: %w[StreakMate 習慣化], via: ENV["X_SHARE_VIA"])
    url = shareable_url_for(resource)
    return unless url

    tweet_text = text.presence || default_share_text(resource)

    link_to "Xで共有",
            x_intent_url(text: tweet_text, url: url, hashtags: hashtags, via: via),
            target: "_blank",
            rel: "noopener noreferrer",
            data: { turbo: false },
            class: "inline-flex items-center gap-1 px-3 py-1.5 text-sm rounded-full border border-gray-300 hover:bg-gray-50"
  end
end
