import Link from "next/link";
import { getSiteContent } from "../lib/content";

export const dynamic = "force-static";

export default async function HomePage() {
    const { problems, abstractHtml } = await getSiteContent();

    return (
        <div className="page">
            <div className="page-header">
                <p className="eyebrow">position paper · forall r&d</p>
                <h1>Tractable Problems in AI Security via Formal Methods</h1>
                <p>
                    A minimal, sane catalog of formal-methods opportunities
                    across the ML training and inference stack. An instruction
                    manual for how to spend 5–25 postdoc-years.
                </p>
                <p className="mt-2">
                    We welcome new contributions: reach out at{" "}
                    <a
                        href="mailto:quinn@for-all.dev"
                        className="prompt"
                        style={{ color: "var(--green)" }}
                    >
                        quinn@for-all.dev
                    </a>{" "}
                    or{" "}
                    <a
                        href="https://calendar.app.google/9Xir9aEK9ZrdttAr8"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="prompt"
                        style={{ color: "var(--green)" }}
                    >
                        schedule a call
                    </a>
                    . Alternatively, file an issue on GH or submit a PR.
                </p>
            </div>

            <section>
                <p className="text-muted text-xs mb-3">// abstract</p>
                <div
                    className="prose"
                    dangerouslySetInnerHTML={{ __html: abstractHtml }}
                />
            </section>

            <section style={{ marginTop: "2.5rem" }}>
                <p className="text-muted text-xs mb-3">// tractable problems</p>
                {problems.map((p) => (
                    <div key={p.id} className="problem-card">
                        <h2>
                            <Link href={`/problems/${p.id}`}>{p.title}</Link>
                        </h2>
                        <div>
                            {p.layers.map((l) => (
                                <Link key={l} href={`/stack/${l}`} className="tag-badge">
                                    {l}
                                </Link>
                            ))}
                        </div>
                    </div>
                ))}
            </section>

            <footer
                style={{
                    marginTop: "3rem",
                    paddingTop: "1rem",
                    borderTop: "1px solid var(--border)",
                    color: "var(--muted)",
                    fontSize: "0.75rem",
                }}
            >
                <p>
                    <Link href="/about">authors</Link>
                    {" · "}
                    <a
                        href="https://calendar.app.google/9Xir9aEK9ZrdttAr8"
                        target="_blank"
                        rel="noopener noreferrer"
                    >
                        calendly
                    </a>
                    {" · "}
                    <Link href="/problems">problems</Link>
                </p>
            </footer>
        </div>
    );
}
