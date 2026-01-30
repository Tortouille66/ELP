export class Player {
  constructor(id, name) {
    this.id = id;
    this.name = name;

    this.hand = [];
    this.roundPoints = 0;
    this.stopped = false;
    this.busted = false;

    this.totalScore = 0;
  }

  resetForNewRound() {
    this.hand = [];
    this.roundPoints = 0;//
    this.stopped = false;
    this.busted = false;
  }
}
