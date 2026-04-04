export interface Problem {
  id: string
  tag: string
  layers: string[]
  category: "enabler" | "widget"
  authors: string[]
  title: string
  html: string
  preview: string
}
