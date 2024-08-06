import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["message"]
  messageTargetConnected() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
