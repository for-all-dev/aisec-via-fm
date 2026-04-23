import fsSync from "fs";
import path from "path";
import { getSiteContent } from "../../lib/content";

export const dynamic = "force-static";

interface Author {
    name: string;
    slug: string;
    organization: string;
    role: string;
    location: string;
    email: string;
}

const AUTHORS: Author[] = JSON.parse(
    fsSync.readFileSync(
        path.join(process.cwd(), "..", "paper", "common", "authors.json"),
        "utf-8",
    ),
);

export default async function AboutPage() {
    const { problems } = await getSiteContent();

    return (
        <div className="page">
            <div className="page-header">
                <p className="eyebrow">disclaimer</p>
                <h1>LLM usage</h1>
                <p>
                    Portions of this document — prose, code scaffolding, and
                    bibliography wrangling — were drafted with assistance from
                    large language models (primarily Claude). Every claim,
                    citation, and technical recommendation is reviewed by a
                    human author before merge, and authorship in the section
                    below reflects accountability for the final text rather than
                    keystroke origin.
                </p>
                <p>
                    If you spot a hallucinated citation, a misattributed result,
                    or a technical error, please open an issue or leave a
                    comment on the relevant section — those reports are read and
                    acted on.
                </p>
            </div>

            <div className="page-header">
                <p className="eyebrow">authorship</p>
                <h1>Authors</h1>
                <p>
                    Partial authorship is tracked per-problem via tags in the
                    source files.
                </p>
            </div>

            <section style={{ marginBottom: "2rem" }}>
                {AUTHORS.map((a) => {
                    const contributed = problems.filter((p) =>
                        p.authors.includes(a.slug),
                    );
                    return (
                        <div key={a.name} className="author-card">
                            <p className="name">{a.name}</p>
                            <p className="meta">
                                {a.role} · {a.organization} · {a.location}
                            </p>
                            <p>
                                <a href={`mailto:${a.email}`}>{a.email}</a>
                            </p>
                            {contributed.length > 0 && (
                                <div style={{ marginTop: "0.75rem" }}>
                                    <p
                                        style={{
                                            color: "var(--muted)",
                                            fontSize: "0.75rem",
                                            marginBottom: "0.25rem",
                                        }}
                                    >
                                        // contributions
                                    </p>
                                    <div>
                                        {contributed.map((p) => (
                                            <a
                                                key={p.id}
                                                href={`/problems/${p.id}`}
                                                className="tag-badge"
                                            >
                                                {p.tag}
                                            </a>
                                        ))}
                                    </div>
                                </div>
                            )}
                        </div>
                    );
                })}
            </section>

            <section>
                <p className="text-muted text-xs mb-3">
                    // to claim partial authorship, add your entry to{" "}
                    <code style={{ fontSize: "0.75rem" }}>authors.json</code>{" "}
                    and add{" "}
                    <code style={{ fontSize: "0.75rem" }}>
                        // Authors: your-slug
                    </code>{" "}
                    to the relevant{" "}
                    <code style={{ fontSize: "0.75rem" }}>
                        paper/problems/*.typ
                    </code>{" "}
                    file
                </p>
            </section>
        </div>
    );
}
