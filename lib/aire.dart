import 'dart:math';
import 'dart:ui';

double getTriSurface(List<Offset> triangle) {
  List<double> t = [];
  for (int i = 0; i < triangle.length; i++) {
    t.add((triangle[i] - triangle[(i + 1) % triangle.length]).distance);
  }
  t.sort();
  return 0.25 *
      sqrt((t[2] + t[1] + t[0]) *
          (t[0] - (t[2] - t[1])) *
          (t[0] + t[2] - t[1]) *
          (t[2] + t[1] - t[0]));
}

double getSurface(List<Offset> traj, int idxmin, int idxmax, Offset center) {
  List<Offset> triangle = [];
  double s = 0.0;
  for (int i = idxmin; i < idxmax - 1; i++) {
    triangle = [center, traj[i], traj[i + 1]];
    s += getTriSurface(triangle);
  }
  return s;
}
