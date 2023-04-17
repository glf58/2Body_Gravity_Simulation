import 'package:flutter/material.dart';
import 'dart:math';

import 'package:gravity_2body_simplified/planet.dart';

class simulPainter extends CustomPainter {
  BuildContext context;
  List<Planet> planets;
  int indexSimulation;
  int ndays;
  double fscale;
  double surf1;
  double surf2;
  Paint paintArrow = Paint()
    ..strokeWidth = 3
    ..color = Colors.blue;
  Paint paintArea = Paint()
    ..strokeWidth = 5
    ..color = Colors.green.withOpacity(0.05)
    ..style = PaintingStyle.stroke;
  List<Paint> fill = [
    Paint()..color = Colors.red,
    Paint()..color = Colors.green
  ];
  Paint stroke = Paint()
    ..strokeWidth = 3.0
    ..style = PaintingStyle.stroke;
  simulPainter(this.context, this.planets, this.indexSimulation, this.ndays,
      this.fscale, this.surf1, this.surf2) {
    stroke = stroke
      ..color = Theme.of(context).colorScheme.primary.withOpacity(0.1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    TextPainter txt2;
    const int trace = 30000;
    double r2 = 5.0;
    List<double> r = [r2 * pow(planets[0].m / planets[1].m, 1.0 / 3.0), r2];
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    final double scale = 0.5 * min(w, h) / fscale;
    final double coef = scale / (planets[0].m + planets[1].m);
    final Offset center = Offset(w / 2, h / 2);
    final Offset G = center +
        planets[0].traj.points[indexSimulation] * planets[0].m * coef +
        planets[1].traj.points[indexSimulation] * planets[1].m * coef;
    int nBody = planets.length;
    // final path = Path();
    const arrowSize = 30;
    const arrowAngle = 10.0 * pi / 180.0;

    for (int i = 0; i < nBody; i++) {
      int n = indexSimulation;
      // on trace la trajectoire passee de chaque objet
      for (int j = max(0, n - trace); j < n - 1; j++) {
        canvas.drawLine(
          center + planets[i].traj.points[j] * scale,
          center + planets[i].traj.points[j + 1] * scale,
          stroke,
        );
      }
      //on affiche la position actuelle dans la simulation
      canvas.drawCircle(
          center + planets[i].traj.points[n - 1] * scale, r[i], fill[i]);
      if (n - 1 - ndays > 0) {
        // on affiche la surface balayee depuis le point courant
        for (int j = n - 1 - ndays; j < n - 1; j++) {
          canvas.drawLine(
              G, center + planets[1].traj.points[j] * scale, paintArea);
        }
        txt2 = TextPainter(
            text: TextSpan(
                text:
                    'La surface balayée vaut ${surf2.toStringAsFixed(2)}% de la surface totale',
                style: const TextStyle(color: Colors.blue)),
            textDirection: TextDirection.ltr);
        txt2.layout();
        txt2.paint(canvas, Offset(0.1 * w, 0.9 * h));
      }
      // on trace le vecteur vitesse
      Offset A1 = center + planets[1].traj.points[n - 1] * scale;
      Offset A2 = A1 + planets[1].traj.vitesses[n - 1] * 100;
      double angle = atan2((A2 - A1).dy, (A2 - A1).dx);
      Offset A3 = Offset(A2.dx - arrowSize * cos(angle - arrowAngle),
          A2.dy - arrowSize * sin(angle - arrowAngle));
      Offset A4 = Offset(A2.dx - arrowSize * cos(angle + arrowAngle),
          A2.dy - arrowSize * sin(angle + arrowAngle));

      canvas.drawLine(A1, A2, paintArrow);
      canvas.drawLine(A2, A3, paintArrow);
      canvas.drawLine(A3, A4, paintArrow);
      canvas.drawLine(A4, A2, paintArrow);
      // path.moveTo(A2.dx - arrowSize * cos(angle - arrowAngle),
      //     A2.dy - arrowSize * sin(angle - arrowAngle));
      // path.lineTo(A2.dx, A2.dy);
      // path.moveTo(A2.dx - arrowSize * cos(angle + arrowAngle),
      //     A2.dy - arrowSize * sin(angle + arrowAngle));
      // path.close();
      // canvas.drawPath(path, paintArrow);
    }
    //on affiche le centre de gravite pour reference.
    canvas.drawCircle(G, 3.0, Paint()..color = Colors.yellow);
  }

  @override
  bool shouldRepaint(simulPainter oldDelegate) => true;
}
