module XShareHelper
  # ex) https://twitter.com/intent/tweet?text=...&url=...&hashtags=foo,bar
  def x_intent_url(text:, url:, hashtags: [], via: nil)
    base = "https://twitter.com/intent/tweet"
    q = { text:, url: }
    q[:hashtags] = Array(hashtags).map { |h| h.delete("#").strip }.reject(&:blank?).join(",") if hashtags.present?
    q[:via]      = via if via.present?
    "#{base}?#{q.to_query}"
  end

  # 非公開なら nil を返す（＝ボタンを出さない）
  def shareable_url_for(resource)
    return unless resource

    # 代表的な公開判定（実装に合わせて拡張可）
    if resource.respond_to?(:visibility)
      return unless resource.visibility.to_s == "public"
    elsif resource.respond_to?(:private?) && resource.private?
      return
    elsif resource.respond_to?(:public?) && !resource.public?
      return
    end

    case resource
    when Log
      # ログ詳細が無い前提 → タイムラインの該当カードへ飛ばす
      timeline_index_url(anchor: "log-#{resource.id}")
    when Goal
      goal_url(resource)
    else
      polymorphic_url(resource)
    end
  end

  def default_share_text(resource)
    case resource
    when Log   then "今日もコツコツ記録中"
    when Goal  then "目標を公開しました"
    else            "StreakMateからシェア"
    end
  end

  # できあがった intent へのリンク（新規タブで開く）
  def x_share_link_to(resource, text: nil, hashtags: %w[StreakMate 習慣化])
    url = shareable_url_for(resource)
    return unless url # 非公開は表示しない

    tweet_text = text.presence || default_share_text(resource)
    link_to "Xで共有", x_intent_url(text: tweet_text, url:, hashtags:),
            target: "_blank", rel: "noopener noreferrer",
            class: "inline-flex items-center gap-1 px-3 py-1.5 text-sm rounded-full border border-gray-300 hover:bg-gray-50"
  end
end
