export function clearScreen() {
  // Efface l'écran + remet le curseur en haut (simple et cross-platform)
  process.stdout.write("\x1b[2J\x1b[0f");
}

export function renderGameState({ round, currentPlayer, players }) {
  console.log(`=== Flip7 (mode texte) | Manche #${round} ===\n`);

  for (const p of players) {
    const isCurrent = p.id === currentPlayer.id;
    const prefix = isCurrent ? "" : "   ";

    // On masque les cartes des autres joueurs si tu veux (ici on montre tout pour debug)
    console.log(
      `${prefix}${p.name} | STOP=${p.stopped ? "oui" : "non"} | Main: [${p.hand.join(", ")}] | Points manche: ${p.roundPoints}`
    );
  }

  console.log("");
}

export function renderTurnPrompt(player) {
  console.log(`Tour de ${player.name}.`);
  console.log("Choix:");
  console.log("  1) Tirer une carte");
  console.log("  2) Stop (je m'arrête pour cette manche)");
}
