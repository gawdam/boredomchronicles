import 'dart:io';

import 'package:boredomapp/widgets/boredomgauge.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

final globalKey = GlobalKey();

class HomePageWidget extends StatelessWidget {
  HomePageWidget(
      {super.key,
      required this.context,
      required this.userBoredom,
      this.connectionBoredom,
      required this.userAvatar,
      this.connectionAvatar});
  final userBoredom;
  final connectionBoredom;
  final userAvatar;
  final connectionAvatar;

  final context;

  Widget createGauge(
      context, userBoredom, connectionBoredom, userAvatar, connectionAvatar) {
    var gaugeRange = <GaugeRange>[
      GaugeRange(
        startValue: 0,
        endValue: 22.5,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        startWidth: 10,
        endWidth: 15,
      ),
      GaugeRange(
        startValue: 25,
        endValue: 47.5,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
        startWidth: 15,
        endWidth: 20,
      ),
      GaugeRange(
        startValue: 50,
        endValue: 72.5,
        color: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(0.8), // Set the color to grey
        startWidth: 20,
        endWidth: 25,
      ),
      GaugeRange(
        startValue: 75,
        endValue: 100,
        color: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(1), // Set the color to grey
        startWidth: 25,
        endWidth: 30,
      ),
    ];
    var gaugeAnnotation = <GaugeAnnotation>[
      GaugeAnnotation(
        widget: Container(
          child: const Text(
            '😐', // Emoji representing boredom level
            style: TextStyle(fontSize: 20),
          ),
        ),
        angle: 180 + (12.5 * 1.8), // Angle for 12.5% level
        positionFactor: 1.25,
      ),
      GaugeAnnotation(
        widget: Container(
          child: const Text(
            '😕', // Emoji representing boredom level
            style: TextStyle(fontSize: 20),
          ),
        ),
        angle: 180 + (37.5 * 1.8), // Angle for 37.5% level
        positionFactor: 1.25,
      ),
      GaugeAnnotation(
        widget: Container(
          child: const Text(
            '😟', // Emoji representing boredom level
            style: TextStyle(fontSize: 20),
          ),
        ),
        angle: 180 + (62.5 * 1.8), // Angle for 62.5% level
        positionFactor: 1.25,
      ),
      GaugeAnnotation(
        widget: Container(
          child: const Text(
            '😫', // Emoji representing boredom level
            style: TextStyle(fontSize: 20),
          ),
        ),
        angle: 180 + (87.5 * 1.8), // Angle for 87.5% level
        positionFactor: 1.25,
      ),
    ];

    return SfRadialGauge(
      backgroundColor: Colors.transparent,
      axes: <RadialAxis>[
        RadialAxis(
            showLabels: false,
            showTicks: false,
            minimum: 0,
            maximum: 100,
            startAngle: 180,
            endAngle: 360,
            axisLineStyle: const AxisLineStyle(color: Colors.transparent),
            radiusFactor: 0.8, // Set radius factor for a semicircle
            ranges: gaugeRange,
            annotations: gaugeAnnotation,
            pointers: <GaugePointer>[
              if (connectionBoredom != null)
                MarkerPointer(
                  overlayRadius: 1,
                  enableDragging: false,
                  value: connectionBoredom,
                  // color: const Color.fromARGB(
                  //     255, 110, 110, 110), // Color of the marker pointer
                  // markerOffset: 3, // Offset to position the marker pointer
                  // markerType: MarkerType.image,
                  // imageUrl: 'assets/images/greyscale/${connectionAvatar}',
                  // markerWidth: 60,
                  // markerHeight: 60,
                  // enableAnimation: true,
                  // animationDuration: 500,

                  color: Color.fromARGB(
                      255, 193, 175, 159), // Color of the marker pointer
                  markerOffset: 5, // Offset to position the marker pointer
                  markerType: MarkerType.circle,
                  borderColor: Color.fromARGB(255, 88, 56, 28),
                  borderWidth: 5,
                  // imageUrl: ' assets/images/man.png',

                  markerWidth: 40,
                  markerHeight: 40,
                ),
              MarkerPointer(
                overlayRadius: 1,

                enableDragging: false,
                value: userBoredom,

                color: Color.fromRGBO(
                    158, 151, 161, 1), // Color of the marker pointer
                markerOffset: 5, // Offset to position the marker pointer
                markerType: MarkerType.circle,
                borderColor: Color.fromARGB(255, 76, 35, 84),
                borderWidth: 5,
                // imageUrl: ' assets/images/man.png',

                markerWidth: 40,
                markerHeight: 40,
                // enableAnimation: true,
                // animationDuration: 500,
              ),
            ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.6,
        child: MediaQuery(
          data: MediaQueryData(),
          child:
              // CircleAvatar(
              //   radius: 55,
              //   backgroundImage: const AssetImage('assets/images/sloth.png'),
              //   backgroundColor: Theme.of(context).canvasColor,
              // ),
              createGauge(
            context,
            userBoredom,
            connectionBoredom,
            userAvatar,
            connectionAvatar,
          ),
        ),
      ),
    );
  }
}
