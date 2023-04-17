import 'dart:math';
import 'dart:ui';
import 'planet.dart';

List<double> getForces(List<double> Z, List<double> M, double G) {
  final epsSquared = 0.0001;
  List<double> res = List.filled(Z.length, 0.0);
  final n = M.length;
  double xx, yy, deno = 0.0;
  for (int i = 0; i < n; i++) {
    res[i] = Z[2 * n + i];
    res[n + i] = Z[3 * n + i];
    xx = 0.0;
    yy = 0.0;
    for (int j = 0; j < n; j++) {
      if (i != j) {
        deno = pow(
                pow(Z[i] - Z[j], 2).toDouble() +
                    pow(Z[i + n] - Z[j + n], 2).toDouble() +
                    epsSquared,
                -1.5)
            .toDouble();
        xx -= M[j] * (Z[i] - Z[j]) * deno;
        yy -= M[j] * (Z[i + n] - Z[j + n]) * deno;
      }
    }
    // print('$i, $xx, $yy');
    res[2 * n + i] = xx * G;
    res[3 * n + i] = yy * G;
  }
  return res;
}

void computeNextStep(
    List<Planet> planets, List<double> Z, List<double> M, double G, double dt) {
  List<double> aux = List.filled(Z.length, 0.0);
  final k1 = getForces(Z, M, G);
  for (int i = 0; i < Z.length; i++) {
    aux[i] = Z[i] + 0.5 * dt * k1[i];
  }
  final k2 = getForces(aux, M, G);
  for (int i = 0; i < Z.length; i++) {
    aux[i] = Z[i] + 0.5 * dt * k2[i];
  }
  final k3 = getForces(aux, M, G);
  for (int i = 0; i < Z.length; i++) {
    aux[i] = Z[i] + dt * k3[i];
  }
  final k4 = getForces(aux, M, G);
  for (int i = 0; i < Z.length; i++) {
    Z[i] += dt / 6.0 * (k1[i] + 2 * k2[i] + 2 * k3[i] + k4[i]);
  }
  for (int i = 0; i < planets.length; i++) {
    planets[i].traj.points.add(Offset(Z[i], Z[i + planets.length]));
    planets[i].traj.Xmin = min(Z[i], planets[i].traj.Xmin);
    planets[i].traj.Ymin = min(Z[i + planets.length], planets[i].traj.Ymin);
    planets[i].traj.Xmax = max(Z[i], planets[i].traj.Xmax);
    planets[i].traj.Ymax = max(Z[i + planets.length], planets[i].traj.Ymax);
    planets[i]
        .traj
        .vitesses
        .add(Offset(Z[i + 2 * planets.length], Z[i + 3 * planets.length]));
  }
}
