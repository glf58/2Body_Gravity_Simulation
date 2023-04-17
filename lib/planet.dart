import 'package:flutter/material.dart';

class Trajectoire {
  List<Offset> points = [];
  List<Offset> vitesses = [];
  double Xmin = 1.0e9;
  double Ymin = 1.0e9;
  double Xmax = -1.0e9;
  double Ymax = -1.0e9;
  Trajectoire(
      this.points, this.vitesses, this.Xmin, this.Xmax, this.Ymin, this.Ymax);
}

class Planet {
  double m;
  double x;
  double y;
  double vx;
  double vy;
  Trajectoire traj = Trajectoire([], [], 1.0e9, -1.0e9, 1.0e9, -1.0e9);
  Planet(this.m, this.x, this.y, this.vx, this.vy, this.traj);
}

class PlanetSimulation {
  double G;
  double dt;
  int nSim;
  int duree; //duree de l'animation en s
  int fps; //images par secondes
  List<Planet> planets;
  double fracPeriod;
  double e;
  double eslider;
  double T;
  PlanetSimulation(this.G, this.dt, this.nSim, this.duree, this.fps,
      this.planets, this.fracPeriod, this.e, this.eslider, this.T);
}

Planet p1 = Planet(
    1.0, 0, 300, -0.1, 0, Trajectoire([], [], 1.0e9, -1.0e9, 1.0e9, -1.0e9));
Planet p2 = Planet(1.0, 0.0, -300.0, 1.0, 0.0,
    Trajectoire([], [], 1.0e9, -1.0e9, 1.0e9, -1.0e9));

PlanetSimulation DefaultSimulation =
    PlanetSimulation(1.0, 1.0, 1000, 10, 20, [p1, p2], 0.1, 0.5, 0.5, 500.0);
