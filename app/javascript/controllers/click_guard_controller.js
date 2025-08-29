// 送信時に1回だけ実行して、ボタンをスピナー表示に変えてロックする
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { cooldown: { type: Number, default: 1000 } } // お好みで

  submit(event) {
    // すでにロック済みなら、送信を止める（多重送信防止）
    if (this.locked) {
      event.preventDefault()
      return
    }
    this.locked = true

    // form 内の送信ボタンを取得（button_to は <form><button>… になる）
    const btn = this.element.querySelector('button, input[type="submit"]')
    if (btn) {
      // 無効化
      btn.disabled = true

      // ボタン中身をスピナー＋文言に差し替え（button エレメントのみ）
      if (btn.tagName.toLowerCase() === "button") {
        btn.innerHTML = `
          <span class="inline-flex items-center gap-2">
            <svg class="animate-spin h-4 w-4" viewBox="0 0 24 24" aria-hidden="true">
              <circle class="opacity-25" cx="12" cy="12" r="10"
                      stroke="currentColor" stroke-width="4" fill="none"></circle>
              <path class="opacity-75" fill="currentColor"
                    d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path>
            </svg>
            <span>処理中...</span>
          </span>
        `
      } else if (btn.type === "submit") {
        // input[type=submit] の場合は value を変更
        btn.value = "処理中..."
      }
    }

    // 念のため：一定時間後にアンロック（Turboの戻りが超速でも二度送信しないよう保険）
    setTimeout(() => { this.locked = false }, this.cooldownValue)
  }
}
