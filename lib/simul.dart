import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gravity_2body_simplified/planet.dart';
import 'package:gravity_2body_simplified/simulpainter.dart';
import 'aire.dart';
import 'computeTraj.dart';
import 'inputs.dart';
import 'orbit.dart';

class simulGravity2bodySimplified extends StatefulWidget {
  const simulGravity2bodySimplified({super.key});

  @override
  State<simulGravity2bodySimplified> createState() =>
      _simulGravity2bodySimplified();
}

class _simulGravity2bodySimplified extends State<simulGravity2bodySimplified>
    with SingleTickerProviderStateMixin {
  // initialisation
  PlanetSimulation paramSim = DefaultSimulation;
  double scale = 1.0;
  List<double> Z = [];
  List<double> M = [];
  int indexSim = 1;
  double surf1 = 1.0;
  double surf2 = 1.0;
  late AnimationController _anim;
  int cpteur = 0;

  @override
  void initState() {
    super.initState();
    InitializeSimul(paramSim.planets);

    scale = getScale(paramSim.planets);
    _anim = AnimationController(
        vsync: this, duration: Duration(seconds: paramSim.duree))
      ..addListener(_onTick);
  }

  void _onTick() {
    cpteur++;
    indexSim = (cpteur * paramSim.nSim) ~/ (paramSim.fps * paramSim.duree);
    // indexSim = cpteur;
    indexSim = min(indexSim, paramSim.nSim - 1);

    final coef = 1.0 / (paramSim.planets[0].m + paramSim.planets[1].m);
    final Offset Gini =
        paramSim.planets[0].traj.points[0] * paramSim.planets[0].m * coef +
            paramSim.planets[1].traj.points[0] * paramSim.planets[1].m * coef;
    final Offset G = paramSim.planets[0].traj.points[indexSim] *
            paramSim.planets[0].m *
            coef +
        paramSim.planets[1].traj.points[indexSim] *
            paramSim.planets[1].m *
            coef;
    var surfaceTotale = (paramSim.e < 1)
        ? getOrbitSurface(paramSim) *
            pow(paramSim.planets[0].m / (1.0 + paramSim.planets[0].m), 2)
        : 1.0;
    final ndays = (paramSim.T * paramSim.fracPeriod) ~/ paramSim.dt;

    return setState(() {
      // indexSim = min(indexSim + 1, nSim - 2);
      if (paramSim.e < 1.0) {
        surf1 = 1.0;
        surf2 = 100.0 *
            getSurface(paramSim.planets[1].traj.points,
                max(indexSim - ndays, 0), indexSim + 1, G) /
            surfaceTotale;
      } else {
        surf1 = getSurface(paramSim.planets[1].traj.points, 0, ndays + 1, Gini);
        surf2 = 100.0 *
            getSurface(paramSim.planets[1].traj.points,
                max(indexSim - ndays, 0), indexSim + 1, G) /
            surf1;
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          // color: Colors.black,
          child: CustomPaint(
            painter: simulPainter(
                context,
                paramSim.planets,
                indexSim,
                (paramSim.T * paramSim.fracPeriod).toInt(),
                scale,
                surf1,
                surf2),
          ),
        ),
        Positioned(
            top: 10,
            right: 10,
            child: Inputs(param: paramSim, start: startSimul)),
      ],
    );
  }

  void startSimul() {
    return setState(() {
      indexSim = 1;
      cpteur = 0;
      InitializeSimul(paramSim.planets);
      scale = getScale(paramSim.planets);
      surf1 = 1.0;
      surf2 = 1.0;
      _anim.duration = Duration(seconds: paramSim.duree);
      _anim.value = 0.0;
      _anim.forward();
    });
  }

  void InitializeSimul(List<Planet> pl) {
    M = [for (Planet p in pl) p.m];
    Z = [
      pl[0].x,
      pl[1].x,
      pl[0].y,
      pl[1].y,
      pl[0].vx,
      pl[1].vx,
      pl[0].vy,
      pl[1].vy
    ];
    // print('dans init, Z:$Z, M:$M, G:${paramSim.G}');
    pl[0].traj.points = [Offset(Z[0], Z[2])];
    pl[1].traj.points = [Offset(Z[1], Z[3])];
    pl[0].traj.vitesses = [Offset(Z[4], Z[6])];
    pl[1].traj.vitesses = [Offset(Z[5], Z[7])];
    pl[0].traj.Xmax = Z[0];
    pl[0].traj.Xmin = Z[0];
    pl[0].traj.Ymax = Z[2];
    pl[0].traj.Ymin = Z[2];
    pl[1].traj.Xmax = Z[1];
    pl[1].traj.Xmin = Z[1];
    pl[1].traj.Ymax = Z[3];
    pl[1].traj.Ymin = Z[3];
    for (int n = 1; n < paramSim.nSim; n++) {
      computeNextStep(pl, Z, M, paramSim.G, paramSim.dt);
    }
    // print('a la fin Z:$Z');
  }

  double getScale(List<Planet> pl) {
    double scaleX = [for (Planet p in pl) p.traj.Xmax].reduce(max) -
        [for (Planet p in pl) p.traj.Xmin].reduce(min);
    double scaleY = [for (Planet p in pl) p.traj.Ymax].reduce(max) -
        [for (Planet p in pl) p.traj.Ymin].reduce(min);

    return (max(scaleX, scaleY));
  }

  void endSimul() {
    return setState(() {
      _anim.stop();
    });
  }
}
