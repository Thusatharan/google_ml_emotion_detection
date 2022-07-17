import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_example/features/home/controller/home_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeController = HomeController();

  String? detectedStress;
  int xAxis = 0;
  double stressPercentage = 0;

  final List<StressData> chartData = [
    StressData(0, 0),
  ];

  String detectStress(happy, other) {
    if (happy != null && other != null) {
      if (happy == "Low" && other == "High") {
        detectedStress = "High Depression";
        stressPercentage = 100;
        return "High Depression";
      }

      if (happy == "High" && other == "Low") {
        detectedStress = "Not Depressed";
        stressPercentage = 0;
        return "Not Depressed";
      }

      if (happy == "Low" && other == "Low") {
        detectedStress = "Sad";
        stressPercentage = 25;
        return "Sad";
      }
      if (happy == "High" && other == "High") {
        detectedStress = "Midly Depressed";

        stressPercentage = 50;
        return "Midly Depressed";
      }

      if (happy == "Moderate" && other == "Low") {
        detectedStress = "Sad";
        return "Sad";
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stress Detection'),
      ),
      body: GetBuilder<HomeController>(
        init: _homeController,
        initState: (_) async {
          await _homeController.loadCamera();
          _homeController.startImageStream();
        },
        builder: (_) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _.cameraController != null &&
                        _.cameraController!.value.isInitialized
                    ? Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: CameraPreview(_.cameraController!))
                    : Center(child: Text('loading')),
                SizedBox(height: 15),
                // Expanded(
                //   child: Container(
                //     alignment: Alignment.topCenter,
                //     width: 200,
                //     height: 200,
                //     color: Colors.white,
                //     child: Image.asset(
                //       'images/${_.faceAtMoment}',
                //       fit: BoxFit.fill,
                //     ),
                //   ),
                // ),
                Text(
                  'Face : ${_.label}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'Emotion : ${_.otherLabel}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(98, 168, 89, 1),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(98, 168, 89, 1),
                              blurRadius: 3.0, // soften the shadow
                              spreadRadius: 2.0, //extend the shadow
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Happy feature level',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              '${_.happyLevel}',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(98, 168, 89, 1),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(98, 168, 89, 1),
                              blurRadius: 3.0, // soften the shadow
                              spreadRadius: 2.0, //extend the shadow
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Other feature level',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              '${_.otherLevel}',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                ElevatedButton(
                    onPressed: (_.happyLevel != "No face" &&
                            _.otherLevel != "No face")
                        ? () => {
                              detectStress(_.happyLevel, _.otherLevel),
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      new AlertDialog(
                                        title:
                                            new Text('Detected Stress Level'),
                                        content: new Text(
                                          detectedStress!,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        actions: <Widget>[
                                          new IconButton(
                                              icon: new Icon(Icons.close),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              })
                                        ],
                                      )),
                              xAxis += 1,
                              chartData.add(StressData(xAxis, stressPercentage))
                              // if (_.label == 'Big smile with teeth')
                              //   {
                              //     setState(() {
                              //       happyCount = happyCount + 1;
                              //     })
                              //   },
                              // if (_.label == 'Big Smile')
                              //   {
                              //     setState(() {
                              //       notStressedCount = notStressedCount + 1;
                              //     })
                              //   },
                              // if (_.label == 'Smile')
                              //   {
                              //     setState(() {
                              //       normalCount = normalCount + 1;
                              //     })
                              //   },
                              // if (_.label == 'Sad')
                              //   {
                              //     setState(() {
                              //       stressed = stressed + 1;
                              //     })
                              //   },
                            }
                        : null,
                    child: Icon(Icons.camera_alt)),

                SfCartesianChart(
                    primaryXAxis: NumericAxis(),
                    title: ChartTitle(text: 'Emotion Level'),
                    series: <ChartSeries>[
                      // Renders line chart
                      LineSeries<StressData, int>(
                          dataSource: chartData,
                          xValueMapper: (StressData stressData, _) =>
                              stressData.time,
                          yValueMapper: (StressData stressData, _) =>
                              stressData.stress)
                    ]),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StressData {
  StressData(this.time, this.stress);
  final int time;
  final double stress;
}


    // SizedBox(
    //               width: 200,
    //               child: ListView(
    //                 shrinkWrap: true,
    //                 children: [
    //                   SizedBox(
    //                     height: 10,
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.all(8.0),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text('Big smile with teeth'),
    //                         Text(happyCount.toString()),
    //                       ],
    //                     ),
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.all(8.0),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text('Not Stressed'),
    //                         Text(notStressedCount.toString()),
    //                       ],
    //                     ),
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.all(8.0),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text('Normal'),
    //                         Text(normalCount.toString()),
    //                       ],
    //                     ),
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.all(8.0),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text('Stressed'),
    //                         Text(stressed.toString()),
    //                       ],
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),