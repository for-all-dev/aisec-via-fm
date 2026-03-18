import type { NextConfig } from "next";
import { execSync } from "child_process";

const commit = (() => {
  try {
    return execSync("git rev-parse --short HEAD", { cwd: __dirname }).toString().trim();
  } catch {
    return "dev";
  }
})();

const buildDate = new Date().toISOString().slice(0, 10);

const nextConfig: NextConfig = {
  env: {
    NEXT_PUBLIC_GIT_COMMIT: commit,
    NEXT_PUBLIC_BUILD_DATE: buildDate,
  },
  serverExternalPackages: ["@myriaddreamin/typst-ts-node-compiler"],
};

export default nextConfig;
