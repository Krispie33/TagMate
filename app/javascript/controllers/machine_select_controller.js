import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["brand", "model"]
  static values = { models: Object }

  connect() {
    this.updateModels()
  }

  updateModels() {
    const brand = this.brandTarget.value
    const models = this.modelsValue[brand] || []
    const modelSelect = this.modelTarget

    const currentValue = modelSelect.value
    modelSelect.innerHTML = '<option value="">Select model</option>'

    models.forEach(model => {
      const option = document.createElement("option")
      option.value = model
      option.text = model
      if (model === currentValue) option.selected = true
      modelSelect.appendChild(option)
    })
  }
}
