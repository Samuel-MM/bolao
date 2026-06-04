import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  open() {
    this.sidebarTarget.classList.add("open")
    this.overlayTarget.classList.add("open")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.sidebarTarget.classList.remove("open")
    this.overlayTarget.classList.remove("open")
    document.body.style.overflow = ""
  }
}
