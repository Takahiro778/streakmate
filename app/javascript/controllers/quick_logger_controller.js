import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["categoryField", "minutesField", "memoField"]

  setCategory(e) {
    const category = e.currentTarget.dataset.category
    this.categoryFieldTarget.value = category
    // 視覚的に選択中のスタイルを切り替えるならここで操作
    this.highlightSelectedCategory(category)
  }

  setMinutesAndSubmit(e) {
    const minutes = e.currentTarget.dataset.minutes
    this.minutesFieldTarget.value = minutes

    // カテゴリが未選択なら最初のボタンを自動選択（好みで）
    if (!this.categoryFieldTarget.value) {
      const first = this.element.querySelector("[data-category]")
      if (first) {
        this.categoryFieldTarget.value = first.dataset.category
        this.highlightSelectedCategory(first.dataset.category)
      }
    }

    // 送信
    this.element.requestSubmit()
  }

  submitIfReady(e) {
    // Enter で送信（Shift+Enter は改行にしたい場合は判定を追加）
    if (!e.shiftKey) {
      e.preventDefault()
      // 必須フィールドがあればチェック
      if (!this.minutesFieldTarget.value) {
        // デフォルト値（15分など）を自動設定して送る手もある
        this.minutesFieldTarget.value = 15
      }
      if (!this.categoryFieldTarget.value) {
        const first = this.element.querySelector("[data-category]")
        if (first) {
          this.categoryFieldTarget.value = first.dataset.category
          this.highlightSelectedCategory(first.dataset.category)
        }
      }
      this.element.requestSubmit()
    }
  }

  highlightSelectedCategory(category) {
    this.element.querySelectorAll("[data-category]").forEach(btn => {
      const active = btn.dataset.category === category
      btn.classList.toggle("bg-gray-900", active)
      btn.classList.toggle("text-white", active)
    })
  }
}
