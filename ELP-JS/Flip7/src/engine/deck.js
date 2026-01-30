export class Deck {
  constructor(cards) {
    this.cards = [...cards];
    this.shuffle();
  }

  shuffle() {
    // Fisher–Yates
    for (let i = this.cards.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [this.cards[i], this.cards[j]] = [this.cards[j], this.cards[i]];
    }
  }

  draw() {
    if (this.cards.length === 0) return null;
    return this.cards.pop();
  }
}

// création du deck par défaut

export function buildDefaultDeck() {

  const cards = [];
  for (let n = 0; n <= 12; n++) {
    for (let k = 0; k < n; k++) { cards.push(n); }
  }
  cards.push(0);
  return cards;
}