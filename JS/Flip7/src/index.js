import { ask, closePrompt } from "./cli/prompt.js";
import { clearScreen, renderGameState, renderTurnPrompt } from "./cli/ui.js";
import { Player } from "./engine/player.js";
import { Game } from "./engine/game.js";
import { Rules } from "./engine/rules.js";
import { Logger } from "./log/logger.js";

async function main() {
  clearScreen();
  console.log("Flip7 (mode texte)\n");

  const nStr = await ask("Nombre de joueurs ? ");
  const n = Math.max(2, Number.parseInt(nStr, 10) || 2);

  const players = [];
  for (let i = 0; i < n; i++) {
    const name = await ask(`Nom du joueur ${i + 1} ? `);
    players.push(new Player(i + 1, name || `Joueur${i + 1}`));
  }

  const logger = new Logger();
  const game = new Game({ players, logger });

  game.startNewRound();

  // Boucle de manche
  while (!Rules.isRoundOver(game.players)) {
    const p = game.currentPlayer;

    clearScreen();
    renderGameState({ round: game.round, currentPlayer: p, players: game.players });

    renderTurnPrompt(p);
    const choice = await ask("> ");

    if (choice === "1") {
      const res = game.drawForCurrentPlayer();
      if (res.type === "draw") {
        console.log(`\n${p.name} tire: ${res.card} | Points manche: ${res.roundPoints}`);
        if (res.busted) console.log(`⚠️ ${p.name} a BUST (doublon placeholder) !`);
      } else {
        console.log("\nPlus de cartes dans le deck (placeholder).");
      }
      await ask("\nEntrée pour continuer...");
    } else if (choice === "2") {
      game.stopCurrentPlayer();
      console.log(`\n${p.name} s'arrête.`);
      await ask("\nEntrée pour continuer...");
    } else {
      console.log("\nChoix invalide.");
      await ask("\nEntrée pour continuer...");
    }

    game.nextPlayer();
  }

  clearScreen();
  console.log("=== Fin de manche (placeholder) ===\n");
  for (const p of game.players) {
    console.log(`${p.name}: ${p.busted ? "BUST" : p.roundPoints + " pts"} | Main: [${p.hand.join(", ")}]`);
  }

  console.log("\nLog enregistré dans:", game.logger.filePath);
  closePrompt();
}

main().catch(err => {
  console.error(err);
  closePrompt();
  process.exit(1);
});
