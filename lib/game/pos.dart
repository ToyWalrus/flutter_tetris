class Pos {
  final int x;
  final int y;
  const Pos(this.x, this.y);

  Pos offsetX(int amt) => Pos(x + amt, y);
  Pos offsetY(int amt) => Pos(x, y + amt);
  Pos offsetXY(int xAmt, int yAmt) => Pos(x + xAmt, y + yAmt);
}