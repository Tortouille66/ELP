import fs from "node:fs";
import path from "node:path";

export class Logger {
  constructor({ dir = "logs", fileName = null } = {}) {
    fs.mkdirSync(dir, { recursive: true });
    const stamp = new Date().toISOString().replaceAll(":", "-");
    this.filePath = path.join(dir, fileName ?? `game-${stamp}.jsonl`);
  }

  log(event) {
    const line = JSON.stringify({
      t: new Date().toISOString(),
      ...event
    });
    fs.appendFileSync(this.filePath, line + "\n", "utf8");
  }
}
