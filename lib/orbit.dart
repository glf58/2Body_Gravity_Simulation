import 'dart:math';
import 'dart:ui';

import 'package:gravity_2body_simplified/planet.dart';

num computeAfromT(double mu, double T) {
  return pow(mu * T * T / 4.0 / pi / pi, 1.0 / 3.0);
}

num computeV(double mu, double e, double r, double a) {
  double eps = (e < 1.0) ? -1.0 : 1.0;
  return sqrt(mu * (2.0 / r + eps / a));
}

num computeAfromV(double r, double V, double mu) {
  return 1.0 / (2.0 / r - V * V / mu);
}

num computeT(double mu, num a) {
  return 2.0 * pi * sqrt(a * a * a / mu);
}

num Tmin(double r, double mu) {
  return pow(0.5 * pi * pi / mu * r * r * r, 0.5);
}

double computee(Offset r, Offset v, double mu) {
  // attention formule uniquement valable au periastre!!
  return sqrt(
      pow(pow(r.dx * v.dy - r.dy * v.dx, 2) / mu / r.distance - 1.0, 2));
}

void showOrbit(Offset r, Offset v, double mu) {
  num e = computee(r, v, mu);
  if (e < 1.0) {
    print('ellipse e:$e');
    num a = computeAfromV(r.distance, v.distance, mu);
    num T = computeT(mu, a);
    print('a:$a');
    print('T:$T');
  } else {
    print('e: $e');
  }
}

double getOrbitSurface(PlanetSimulation param) {
  double M1 = param.planets[0].m;
  double X1 = param.planets[0].x;
  double Y1 = param.planets[0].y;
  double VX1 = param.planets[0].vx;
  double VY1 = param.planets[0].vy;
  double M2 = param.planets[1].m;
  double X2 = param.planets[1].x;
  double Y2 = param.planets[1].y;
  double VX2 = param.planets[1].vx;
  double VY2 = param.planets[1].vy;

  Offset r = Offset(X2 - X1, Y2 - Y1);
  Offset v = Offset(VX2 - VX1, VY2 - VY1);
  double mu = param.G * (M1 + M2);

  double e = computee(r, v, mu);
  double a = computeAfromV(r.distance, v.distance, mu).toDouble();
  double b = sqrt(a * a * (1 - e * e));
  // print('dans calcul surface $e, $a, $b');
  return (pi * a * b);
}
