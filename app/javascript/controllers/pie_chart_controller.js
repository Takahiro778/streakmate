import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { data: Object, title: String }

  connect() {
    console.log("[pie-chart] connect", this.dataValue)
    if (!window.Chart) {
      console.error("[pie-chart] window.Chart がありません"); return
    }
    if (!this.dataValue || Object.keys(this.dataValue).length === 0) return

    const labels = Object.keys(this.dataValue)
    const values = Object.values(this.dataValue)

    const ctx = this.element.getContext("2d")
    this.chart = new window.Chart(ctx, {
      type: "pie",
      data: { labels, datasets: [{ data: values }] },
      options: {
        responsive: true, maintainAspectRatio: false,
        plugins: {
          legend: { position: "bottom" },
          tooltip: { callbacks: { label: (c) => `${c.label}: ${c.parsed} 分` } }
        }
      }
    })
  }

  disconnect() { if (this.chart) this.chart.destroy() }
}
