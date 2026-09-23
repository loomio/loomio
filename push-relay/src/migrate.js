import fs from "node:fs/promises";
import path from "node:path";
import pg from "pg";
import { fileURLToPath } from "node:url";

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) throw new Error("DATABASE_URL is required");
const directory = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../migrations");
const pool = new pg.Pool({ connectionString: databaseUrl, max: 1 });

try {
  for (const filename of (await fs.readdir(directory)).filter((name) => name.endsWith(".sql")).sort()) {
    await pool.query(await fs.readFile(path.join(directory, filename), "utf8"));
    console.log(`applied ${filename}`);
  }
} finally {
  await pool.end();
}
