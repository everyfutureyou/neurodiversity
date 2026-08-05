import { Controller } from "@hotwired/stimulus"

// Enforces pay-what-you-want amount rules: €0 or ≥ €0.50 (Stripe EUR minimum).
export default class extends Controller {
  static targets = ["amount", "error", "submit"]

  connect() {
    this.validate()
  }

  onInput() {
    this.validate()
  }

  setPreset(event) {
    this.amountTarget.value = event.params.euros
    this.validate()
  }

  validate(event) {
    const euros = parseFloat(this.amountTarget.value) || 0
    const cents = Math.round(euros * 100)
    const invalid = cents > 0 && cents < 50

    this.errorTarget.classList.toggle("hidden", !invalid)
    this.submitTarget.disabled = invalid

    if (event && invalid) {
      event.preventDefault()
    }
  }
}
