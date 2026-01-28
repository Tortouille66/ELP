export const Rules = {
  /**
   * Applique une carte tirée au joueur.
   * Retourne un objet décrivant le résultat (pour affichage et log).
   */
  applyDraw(player, card) {
    player.hand.push(card);

    // ✅ Placeholder scoring: somme des cartes
    player.roundPoints = player.hand.reduce((a, b) => a + b, 0);

    // ✅ Placeholder bust: si on tire un doublon, on bust
    const counts = new Map();
    for (const c of player.hand) counts.set(c, (counts.get(c) ?? 0) + 1);
    const hasDuplicate = [...counts.values()].some(v => v >= 2);

    if (hasDuplicate) {
      player.busted = true;
    }

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
