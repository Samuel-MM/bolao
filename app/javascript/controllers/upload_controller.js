import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["file", "button", "progress", "bar", "status", "url"]

  async handleFile() {
    const file = this.fileTarget.files[0]
    if (!file) return

    this.progressTarget.classList.remove("hidden")
    this.statusTarget.textContent = "Enviando..."
    this.buttonTarget.disabled = true

    try {
      const csrfToken = document.querySelector("meta[name=csrf-token]").content
      const response = await fetch("/payments/presigned_url", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ filename: file.name, content_type: file.type })
      })

      if (!response.ok) throw new Error("Erro ao obter URL de upload")

      const { presigned_url, s3_key } = await response.json()

      const uploadResponse = await fetch(presigned_url, {
        method: "PUT",
        body: file,
        headers: { "Content-Type": file.type }
      })

      if (!uploadResponse.ok) throw new Error("Erro no upload para S3")

      this.urlTarget.value = s3_key
      this.barTarget.style.width = "100%"
      this.statusTarget.textContent = "Arquivo enviado! Clique em 'Confirmar' para finalizar."
      this.buttonTarget.disabled = false

    } catch (error) {
      this.statusTarget.textContent = "Erro: " + error.message
      this.barTarget.style.width = "0%"
      this.buttonTarget.disabled = true
    }
  }
}
