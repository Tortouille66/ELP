export class Player {
  constructor(id, name) {
    this.id = id;
    this.name = name;

    this.hand = [];
    this.roundPoints = 0;
    this.stopped = false;
    this.busted = false;
  }

  resetForNewRound() {
    this.hand = [];
    this.roundPoints = 0;
    this.stopped = false;
    this.busted = false;
  }
}
