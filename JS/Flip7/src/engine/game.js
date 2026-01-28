import { Deck, buildDefaultDeck } from "./deck.js";
import { Rules } from "./rules.js";

export class Game {
  constructor({ players, logger }) {
    this.players = players;
    this.logger = logger;

    this.round = 1;
    this.currentIndex = 0;
    this.deck = new Deck(buildDefaultDeckDeckSafe());
  }

  startNewRound() {
    this.players.forEach(p => p.resetForNewRound());
    this.currentIndex = 0;
    this.deck = new Deck(buildDefaultDeckDeckSafe());

    this.logger?.log({
      type: "round_start",
      round: this.round,
      players: this.players.map(p => ({ id: p.id, name: p.name }))
    });
  }

  get currentPlayer() {
    return this.players[this.currentIndex];
  }

  nextPlayer() {
    // saute les joueurs déjà stop/bust
    for (let i = 0; i < this.players.length; i++) {
      this.currentIndex = (this.currentIndex + 1) % this.players.length;
      const p = this.players[this.currentIndex];
      if (!p.stopped && !p.busted) return p;
    }
    return this.currentPlayer;
  }

  drawForCurrentPlayer() {
    const p = this.currentPlayer;
    const card = this.deck.draw();
    if (card === null) {
      // deck vide -> fin de manche (placeholder)
      p.stopped = true;
      return { type: "deck_empty" };
    }

    const result = Rules.applyDraw(p, card);

    this.logger?.log({
      type: "draw",
      round: this.round,
      playerId: p.id,
      playerName: p.name,
      cardDrawn: card,
      hand: [...p.hand],
      roundPoints: p.roundPoints,
      busted: p.busted
    });

    if (p.busted) {
      this.logger?.log({
        type: "bust",
        round: this.round,
        playerId: p.id,
        playerName: p.name
      });
    }

    return { type: "draw", ...result };
  }

  stopCurrentPlayer() {
    const p = this.currentPlayer;
    p.stopped = true;

    this.logger?.log({
      type: "stop",
      round: this.round,
      playerId: p.id,
      playerName: p.name,
      hand: [...p.hand],
      roundPoints: p.roundPoints
    });

    return { type: "stop" };
  }
}

// petite protection au cas où buildDefaultDeck n'existe pas
function buildDefaultDeckDeckSafe() {
  return buildDefaultDeck();
}
