import 'package:boredomapp/providers/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoredomGauge extends ConsumerStatefulWidget {
  final value; // Value to be represented on the gauge
  final onValueChanged;
  const BoredomGauge({
    super.key,
    required this.value,
    required this.onValueChanged,
  });

  @override
  ConsumerState<BoredomGauge> createState() => _BoredomGaugeState();
}

class _BoredomGaugeState extends ConsumerState<BoredomGauge> {
  final connectionAvatar = 'assets/images/man.png';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.invalidate(userProvider);
  }

  Widget createGauge(
      userBoredom, connectionBoredom, userAvatar, _connectionAvatar) {
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
                  color: const Color.fromARGB(
                      255, 110, 110, 110), // Color of the marker pointer
                  markerOffset: 3, // Offset to position the marker pointer
                  markerType: MarkerType.image,
                  imageUrl: 'assets/images/greyscale/${_connectionAvatar}',
                  markerWidth: 60,
                  markerHeight: 60,
                  enableAnimation: true,
                  animationDuration: 500,
                ),
              MarkerPointer(
                overlayRadius: 1,

                enableDragging: true,
                value: widget.value ?? 1,
                onValueChanged: (double newValue) {
                  if (widget.onValueChanged != null) {
                    widget.onValueChanged!(newValue);
                  }
                },

                color: const Color.fromARGB(
                    255, 255, 0, 0), // Color of the marker pointer
                markerOffset: 3, // Offset to position the marker pointer
                markerType: MarkerType.image,
                imageUrl: 'assets/images/${userAvatar}',

                markerWidth: 60,
                markerHeight: 60,
                enableAnimation: true,
                animationDuration: 500,
              ),
            ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return user.when(data: (data) {
      if (data == null) {
        ref.invalidate(userProvider);
        print("NULL DATA");
        return const CircularProgressIndicator();
      }
      return ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 0.6,
          // widthFactor: 0.5,
          child: Center(
            child: FutureBuilder(
                future: getConnection(data),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == 'Loading') {
                    return const Column();
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return createGauge(
                        widget.value,
                        snapshot.data!.boredomValue,
                        data.avatar,
                        snapshot.data!.avatar);
                  } else {
                    return createGauge(widget.value, null, data.avatar, null);
                  }
                }),
          ),
        ),
      );
    }, error: (Object error, StackTrace stackTrace) {
      return Expanded(child: ErrorWidget(error));
    }, loading: () {
      return const CircularProgressIndicator();
    });
  }
}
