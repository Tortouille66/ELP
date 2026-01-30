export class Player {
  constructor(id, name) {
    this.id = id;
    this.name = name;

    this.hand = [];
    this.roundPoints = 0;
    this.stopped = false;
    this.busted = false;

    this.totalScore = 0;

    this.hasChance = false;     // a pioché CHANCE
    this.chanceUsed = false;    // a déjà “consommé” sa seconde chance
  }

  resetForNewRound() {
    this.hand = [];
    this.roundPoints = 0;//
    this.stopped = false;
    this.busted = false;
    this.hasChance = false;
    this.chanceUsed = false;
  }
}
