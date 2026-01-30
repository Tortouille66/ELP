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

  const TARGET_SCORE = 200;

  while (true) {
    game.startNewRound();

    // ===== BOUCLE D’UNE MANCHE =====
    while (!Rules.isRoundOver(game.players)) {
      const p = game.currentPlayer;

      clearScreen();
      renderGameState({
        round: game.round,
        currentPlayer: p,
        players: game.players
      });

      renderTurnPrompt(p);
      const choice = await ask("> ");

      if (choice === "1") {
        const res = game.drawForCurrentPlayer();

        if (res.type === "draw") {
          console.log(`\n${p.name} tire la carte : ${res.card}`);
          // console.log(`Points de la manche : ${res.roundPoints}`);
        }

        if (res.busted) {
          console.log(` ${p.name} a BUST !`);
        }


        await ask("\nEntrée pour continuer...");
      }
      else if (choice === "2") {
        game.stopCurrentPlayer();
        console.log(`\n${p.name} s'arrête pour cette manche.`);
        await ask("\nEntrée pour continuer...");
      }
//
      game.nextPlayer();
    }

    // ===== FIN DE MANCHE =====
    clearScreen();
    console.log(`=== Fin de la manche ${game.round} ===\n`);

    const results = game.endRoundAndApplyScores();
    for (const r of results) {
      console.log(
        `${r.name}: ${r.busted ? "BUST (0)" : "+" + r.gained} | Total: ${r.total}`
      );
    }

    const winner = game.getWinner(TARGET_SCORE);
    if (winner) {
      console.log(`\n🏆 ${winner.name} gagne la partie avec ${winner.totalScore} points !`);
      break;
    }

    await ask("\nNouvelle manche ? (Entrée)");
  }

  closePrompt();

}

main().catch(err => {
  console.error(err);
  closePrompt();
  process.exit(1);
});
