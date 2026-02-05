export const Rules = {
  /**
   * Applique une carte tirée au joueur.
   * Retourne un objet décrivant le résultat (pour affichage et log).
   */
  applyDraw(player, card) {

    player.hand.push(card);

    const isSpecial = typeof card === "object" && card?.kind;
    if (isSpecial) {
      if (card.kind === "CHANCE") {
        player.hasChance = true;
        return { card, roundPoints: player.roundPoints, busted: player.busted, special: "CHANCE" };
      }
      if (card.kind === "FREEZZ") {
        // l'effet STOP sera géré dans game.js (meilleur endroit)
        return { card, roundPoints: player.roundPoints, busted: player.busted, special: "FREEZZ" };
      }
      if (card.kind === "THREE") {
        // la pioche en chaîne sera gérée dans game.js
        return { card, roundPoints: player.roundPoints, busted: player.busted, special: "THREE" };
      }
    }



    // Placeholder scoring: somme des cartes
    player.roundPoints = player.hand.reduce((sum, c) => {
      return sum + (typeof c === "number" ? c : 0);
    }, 0);

    // Placeholder bust: si on tire un doublon, on bust
    const counts = new Map();
    for (const c of player.hand) counts.set(c, (counts.get(c) ?? 0) + 1);
    const hasDuplicate = [...counts.values()].some(v => v >= 2);

    if (hasDuplicate) {
      if (hasDuplicate) {
        // Si le joueur a CHANCE et ne l’a pas encore utilisée : il survit à ce bust
        if (player.hasChance && !player.chanceUsed) {
          player.chanceUsed = true;
          player.busted = false;
          return {
            card,
            roundPoints: player.roundPoints,
            busted: false,
            savedByChance: true
          };
        }

        player.busted = true;
      }
      player.stopped = true; 
      player.roundPoints = 0; 
    }
//
    return {
      card,
      roundPoints: player.roundPoints,
      busted: player.busted
    };
  },

  isRoundOver(players) {
    // Manche finie quand tout le monde est stop OU bust
    return players.every(p => p.stopped || p.busted);
  }
};
