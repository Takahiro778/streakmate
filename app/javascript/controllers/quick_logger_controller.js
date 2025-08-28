import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["categoryField", "minutesField", "memoField", "submitButton"]

  setCategory(e) {
    const category = e.currentTarget.dataset.category
    this.categoryFieldTarget.value = category
    this.highlightSelectedCategory(category)
  }

  setMinutes(e) {
    const minutes = e.currentTarget.dataset.minutes
    this.minutesFieldTarget.value = minutes
    this.highlightSelectedMinutes(minutes)

    // カテゴリが未選択なら最初のカテゴリを選ぶ（任意）
    if (!this.categoryFieldTarget.value) {
      const first = this.element.querySelector("[data-category]")
      if (first) {
        this.categoryFieldTarget.value = first.dataset.category
        this.highlightSelectedCategory(first.dataset.category)
      }
    }

    // minutes 選択時に記録ボタンを有効化
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("bg-gray-400")
      this.submitButtonTarget.classList.add("bg-black")
    }
  }

  submitIfReady(e) {
    if (!e.shiftKey) {  // Shift+Enterは改行
      e.preventDefault()
      if (this.minutesFieldTarget.value && this.categoryFieldTarget.value) {
        this.element.requestSubmit()
      }
    }
  }

  highlightSelectedCategory(category) {
    this.element.querySelectorAll("[data-category]").forEach(btn => {
      const active = btn.dataset.category === category
      btn.classList.toggle("bg-gray-900", active)
      btn.classList.toggle("text-white", active)
    })
  }

  highlightSelectedMinutes(minutes) {
    this.element.querySelectorAll("[data-minutes]").forEach(btn => {
      const active = btn.dataset.minutes === minutes
      btn.classList.toggle("bg-gray-900", active)
      btn.classList.toggle("text-white", active)
    })
  }
}
