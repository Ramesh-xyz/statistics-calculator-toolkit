import 'package:sdtoolkit/sdtoolkit.dart' as sd;

void main() {
  const data = [2, 4, 4, 4, 5, 5, 7, 9];
  print(sd.mean(data)); // 5.0
  print(sd.sampleVariance(data)); // 4.571428571428571
  print(sd.sampleStdev(data)); // 2.138089935299395
  print(sd.relativeStdDev(data)); // 42.7617987059879
  print(sd.describe(data, population: true));

  try {
    sd.sampleStdev([5]);
  } on sd.StatisticsException catch (e) {
    print(e.message); // sample statistics need at least 2 data points, got 1
  }
}
