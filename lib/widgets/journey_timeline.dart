import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:hackaurora_vjti/utils/dummy_data.dart';

class JourneyTimeline extends StatelessWidget {
  const JourneyTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        DummyData.journeySteps.length,
        (index) => TimelineTile(
          isFirst: index == 0,
          isLast: index == DummyData.journeySteps.length - 1,
          endChild: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DummyData.journeySteps[index].title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(DummyData.journeySteps[index].description),
                Text(
                  'Location: ${DummyData.journeySteps[index].location}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // indicators: [
          //   const Icon(Icons.check_circle, color: Colors.green),
          // ],
        ),
      ),
    );
  }
}