import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel"];
  toggle() {
    this.panelTargets.forEach((el) => el.classList.toggle("hidden"));
  }
  hide() {
    this.panelTargets.forEach((el) => el.classList.add("hidden"));
  }
}
