import { Suspense } from "react"
import { getSiteContent } from "../../lib/content"
import { ProblemList } from "../../components/problem-filters"

export const dynamic = "force-static"

export default async function ProblemsPage() {
  const { problems } = await getSiteContent()

  return (
    <div className="page">
      <div className="page-header">
        <p className="eyebrow">tractable problems</p>
        <h1>Shovel-Ready Project Specs</h1>
      </div>

      <Suspense>
        <ProblemList problems={problems} />
      </Suspense>
    </div>
  )
}
