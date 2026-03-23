import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["brand", "model", "brandOther", "modelOther"]
  static values = { models: Object }

  connect() {
    this.updateModels()
    this.toggleBrandOther()
    this.element.closest("form")?.addEventListener("submit", this.handleSubmit.bind(this))
  }

  brandChanged() {
    this.updateModels()
    this.toggleBrandOther()
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

    const otherOption = document.createElement("option")
    otherOption.value = "Other"
    otherOption.text = "Other"
    if (currentValue === "Other") otherOption.selected = true
    modelSelect.appendChild(otherOption)

    this.toggleModelOther()
  }

  toggleBrandOther() {
    const isOther = this.brandTarget.value === "Other"
    this.brandOtherTarget.classList.toggle("d-none", !isOther)

    if (!isOther) {
      this.brandOtherTarget.value = ""
    }
  }

  toggleModelOther() {
    const isOther = this.modelTarget.value === "Other"
    this.modelOtherTarget.classList.toggle("d-none", !isOther)

    if (!isOther) {
      this.modelOtherTarget.value = ""
    }
  }

  handleSubmit() {
    if (this.brandTarget.value === "Other" && this.brandOtherTarget.value.trim()) {
      this.brandOtherTarget.name = this.brandTarget.name
      this.brandTarget.disabled = true
    }
    if (this.modelTarget.value === "Other" && this.modelOtherTarget.value.trim()) {
      this.modelOtherTarget.name = this.modelTarget.name
      this.modelTarget.disabled = true
    }
  }
}
