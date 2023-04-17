import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gravity_2body_simplified/planet.dart';

import 'orbit.dart';

class Inputs extends StatefulWidget {
  final PlanetSimulation param;
  Function start;
  Inputs({Key? key, required this.param, required this.start})
      : super(key: key);

  @override
  InputsState createState() {
    return InputsState();
  }
}

class InputsState extends State<Inputs> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Text('M2/M1: ${widget.param.planets[0].m.toStringAsFixed(0)}'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Slider(
                value: log(widget.param.planets[0].m) / log(10.0),
                min: 0.0,
                max: 4.0,
                label: 'M2/M1',
                onChanged: (val) => setState(() {
                      widget.param.planets[0].m = pow(10.0, val).toDouble();
                    })),
          ),
        ],
      ),
      Row(
        children: [
          Text('e:${widget.param.e.toStringAsFixed(2)}'),
          SizedBox(
            width: 100,
            child: Slider(
                value: widget.param.eslider,
                min: 0.0,
                max: 0.98,
                label: 'e',
                onChanged: (val) => setState(() {
                      widget.param.eslider = val;
                      widget.param.e = val;
                      // widget.param.e =
                      //     (val < 1.0) ? val : pow(10.0, val - 1).toDouble();
                    })),
          ),
          Text('${(widget.param.fracPeriod * 100.0).toStringAsFixed(0)}%'),
          SizedBox(
            width: 100,
            child: Slider(
                value: widget.param.fracPeriod,
                label: 'Loi des aires',
                onChanged: (val) => setState(() {
                      widget.param.fracPeriod = val;
                    })),
          ),
        ],
      ),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
              onPressed: setInitialConditionForOrbit,
              // onPressed: (widget.param.e < 1)
              //     ? setInitialConditionForOrbit
              //     : setInitialConditionForOrbit2,
              child: const Text('Orbite'))),
    ]);
  }

  void setInitialConditionForOrbit() {
    double M1 = widget.param.planets[0].m;
    double M2 = widget.param.planets[1].m;
    double mu = widget.param.G * (M1 + M2);
    double e = widget.param.e;
    double mu1 = M1 / (M1 + M2);
    Offset P1 = const Offset(1.0, 1.0);
    Offset P2 = const Offset(-1.0, -1.0);
    double a = 1.0, r = 1.0;
    if (e < 1.0) {
      a = computeAfromT(mu, widget.param.T).toDouble();
      r = a * (1.0 - e);
    } else {
      a = 200.0;
      r = a * (1.0 + e);
    }
    double V = computeV(mu, e, r, a).toDouble();
    Offset Rini = (P2 - P1) * r / ((P2 - P1).distance);
    widget.param.planets[0].x = -(1.0 - mu1) * Rini.dx;
    widget.param.planets[0].y = -(1.0 - mu1) * Rini.dy;
    widget.param.planets[1].x = mu1 * Rini.dx;
    widget.param.planets[1].y = mu1 * Rini.dy;

    Offset V1 = const Offset(1.0, -1.0);
    Offset V2 = V1 * (-M1 / M2);
    double coef = V / ((V2 - V1).distance);
    Offset Vini = (V2 - V1) * coef;
    widget.param.planets[0].vx = V1.dx * coef;
    widget.param.planets[0].vy = V1.dy * coef;
    widget.param.planets[1].vx = V2.dx * coef;
    widget.param.planets[1].vy = V2.dy * coef;
    print('apres calcul de l orbite');
    print('V1: ${V1 * coef}, V2:${V2 * coef}');
    showOrbit(Rini, Vini, mu);
    if (e < 1) {
      widget.param.dt = (widget.param.e > 0.9) ? 0.1 : 1.0;
      widget.param.nSim = (2.0 * widget.param.T) ~/ widget.param.dt;
    } else {
      widget.param.dt = 10.0;
      widget.param.nSim = 1000;
    }

    widget.start();
  }

// conditions initiales pour les hyperboles
// on cherche a faire partir le point de l'infini pour afficher une traj complete.
  void setInitialConditionForOrbit2() {
    double M1 = widget.param.planets[0].m;
    double M2 = widget.param.planets[1].m;
    double mu = widget.param.G * (M1 + M2);
    double e = widget.param.e;
    double mu1 = M1 / (M1 + M2);
    double a = 200.0;
    if (e > 1.0) {
      double vinf = sqrt(mu / a);
      Offset t = Offset(0.0, 1.0);
      double rinf = 10.0 * a * (1 + e);
      Offset Rinf = t * rinf;
      double sinPsi = a / rinf * sqrt(e * e - 1.0);
      double cosPsi = sqrt(1 - sinPsi * sinPsi);
      Offset Vinf = Offset(
              cosPsi * t.dx + sinPsi * t.dy, -sinPsi * t.dx + cosPsi * t.dy) *
          (-vinf);
      widget.param.planets[0].x = -(1.0 - mu1) * Rinf.dx;
      widget.param.planets[0].y = -(1.0 - mu1) * Rinf.dy;
      widget.param.planets[1].x = mu1 * Rinf.dx;
      widget.param.planets[1].y = mu1 * Rinf.dy;
      widget.param.planets[0].vx = -(1.0 - mu1) * Vinf.dx;
      widget.param.planets[0].vy = -(1.0 - mu1) * Vinf.dy;
      widget.param.planets[1].vx = mu1 * Vinf.dx;
      widget.param.planets[1].vy = mu1 * Vinf.dy;
      widget.param.dt = 100.0;
      widget.param.nSim = 1000;
    } else {
      print('pas implemente');
    }

    widget.start();
  }
}
