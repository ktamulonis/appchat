import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
    if (this.contentTarget.classList.contains("hidden")) {
      this.iconTarget.textContent = "Expand"
    } else {
      this.iconTarget.textContent = "Collapse"
    }
  }
}

