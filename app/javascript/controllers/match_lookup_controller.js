import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["matchId", "homeTeam", "awayTeam", "kickoffAt", "button", "feedback"]
  static values  = { url: String }

  async lookup() {
    const id = this.matchIdTarget.value.trim()
    if (!id) return

    this.buttonTarget.disabled = true
    this.buttonTarget.textContent = "Buscando…"
    this.feedbackTarget.textContent = ""

    try {
      const response = await fetch(`${this.urlValue}?id=${encodeURIComponent(id)}`, {
        headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content }
      })
      const data = await response.json()

      if (response.ok) {
        this.homeTeamTarget.value  = data.home_team  || ""
        this.awayTeamTarget.value  = data.away_team  || ""
        this.kickoffAtTarget.value = this.#toLocalDatetime(data.kickoff_at)
        this.feedbackTarget.textContent = "✓ Dados preenchidos"
        this.feedbackTarget.style.color = "#15803d"
        this.buttonTarget.textContent = "Buscar da API"
      } else {
        this.feedbackTarget.textContent = data.error || "Erro ao buscar jogo"
        this.feedbackTarget.style.color = "#dc2626"
        this.buttonTarget.textContent = "Buscar da API"
      }
    } catch {
      this.feedbackTarget.textContent = "Erro de conexão"
      this.feedbackTarget.style.color = "#dc2626"
      this.buttonTarget.textContent = "Buscar da API"
    } finally {
      this.buttonTarget.disabled = false
    }
  }

  #toLocalDatetime(utcString) {
    if (!utcString) return ""
    const d = new Date(utcString)
    const pad = n => String(n).padStart(2, "0")
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
  }
}
