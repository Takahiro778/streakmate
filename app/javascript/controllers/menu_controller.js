import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this.boundOutside = this.handleOutside.bind(this)
    document.addEventListener("click", this.boundOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundOutside)
  }

  toggle() {
    this.panelTarget.classList.toggle("hidden")
  }

  handleOutside(e) {
    // メニュー外をクリックしたら閉じる
    if (!this.element.contains(e.target)) {
      this.panelTarget.classList.add("hidden")
    }
  }
}
