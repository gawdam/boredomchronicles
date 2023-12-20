import 'package:boredomapp/models/user.dart';
import 'package:boredomapp/providers/userprovider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoredomGauge extends ConsumerStatefulWidget {
  final double value; // Value to be represented on the gauge
  final ValueChanged<double> onValueChanged;
  const BoredomGauge(
      {super.key, required this.value, required this.onValueChanged});

  @override
  ConsumerState<BoredomGauge> createState() => _BoredomGaugeState();
}

class _BoredomGaugeState extends ConsumerState<BoredomGauge> {
  String _getAvatar() {
    final user = ref.watch(userProvider);
    final avatarFile = user.when(
      loading: () => 'assets/images/man.png',
      error: (e, _) => 'assets/images/man.png',
      data: (data) => data != null
          ? 'assets/images/${data.avatar}'
          : 'assets/images/man.png',
    );
    return avatarFile;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.6,
        // widthFactor: 0.5,
        child: Center(
          child: SfRadialGauge(
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
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 22.5,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.4),
                      startWidth: 10,
                      endWidth: 15,
                    ),
                    GaugeRange(
                      startValue: 25,
                      endValue: 47.5,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.6),
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
                  ],
                  annotations: <GaugeAnnotation>[
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
                  ],
                  pointers: <GaugePointer>[
                    MarkerPointer(
                      overlayRadius: 1,

                      enableDragging: true,
                      value: widget.value,
                      onValueChanged: (double newValue) {
                        widget.onValueChanged(newValue);
                      },

                      color: const Color.fromARGB(
                          255, 110, 110, 110), // Color of the marker pointer
                      markerOffset: 3, // Offset to position the marker pointer
                      markerType: MarkerType.image,
                      imageUrl: _getAvatar() ?? 'assets/images/man.png',

                      markerWidth: 60,
                      markerHeight: 60,
                      enableAnimation: true,
                      animationDuration: 500,
                    ),
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
