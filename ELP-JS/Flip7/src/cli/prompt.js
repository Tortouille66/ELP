import readline from "node:readline/promises";
import { stdin as input, stdout as output } from "node:process";

const rl = readline.createInterface({ input, output });

export async function ask(question) {
  const answer = await rl.question(question);
  return answer.trim();
}

export function closePrompt() {
  rl.close();
}
