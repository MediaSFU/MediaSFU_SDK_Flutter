# Custom Builders for MediaSFU Components

This guide explains how to use custom builders to completely customize the appearance and behavior of VideoCard, AudioCard, and MiniCard components in the MediaSFU SDK.

## Overview

The MediaSFU SDK supports custom builder functions that allow you to replace the default VideoCard, AudioCard, and MiniCard components with your own custom implementations. This provides complete control over the visual design and behavior of participant display cards.

## Custom Builder Types

### VideoCardType
```dart
typedef VideoCardType = Widget Function({
  required Participant participant,
  required Stream stream,
  required double width,
  required double height,
  int? imageSize,
  String? doMirror,
  bool? showControls,
  bool? showInfo,
  String? name,
  Color? backgroundColor,
  VoidCallback? onVideoPress,
  dynamic parameters,
});
```

### AudioCardType  
```dart
typedef AudioCardType = Widget Function({
  required String name,
  required bool barColor,
  required Color textColor,
  required String imageSource,
  required double roundedImage,
  required Color imageStyle,
  dynamic parameters,
});
```

### MiniCardType
```dart
typedef MiniCardType = Widget Function({
  required String initials,
  required String fontSize,
  bool? customStyle,
  required String name,
  required bool showVideoIcon,
  required bool showAudioIcon,
  required String imageSource,
  required double roundedImage,
  required Color imageStyle,
  dynamic parameters,
});
```

## Usage

Pass your custom builder functions to the `MediasfuGeneric` component through the `MediasfuGenericOptions`:

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    // Standard options...
    useLocalUIMode: true,
    
    // Custom builders
    customVideoCard: myCustomVideoCard,
    customAudioCard: myCustomAudioCard, 
    customMiniCard: myCustomMiniCard,
  ),
)
```

## Implementation Flow

1. **MediasfuGeneric** receives custom builders in `MediasfuGenericOptions`
2. **MediasfuParameters** stores the custom builders and provides update functions
3. **prepopulate_user_media** consumer checks for custom builders and uses them instead of default components
4. Custom builders are called with appropriate parameters for each participant

## Example Implementation

### Custom VideoCard
```dart
Widget myCustomVideoCard({
  required Participant participant,
  required Stream stream,
  required double width,
  required double height,
  // ... other parameters
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.purple, Colors.blue],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Stack(
      children: [
        // Your custom video display logic
        YourVideoWidget(stream: stream.stream),
        
        // Custom overlay
        if (showInfo == true)
          Positioned(
            top: 8,
            left: 8,
            child: CustomParticipantInfo(participant: participant),
          ),
      ],
    ),
  );
}
```

### Custom AudioCard
```dart
Widget myCustomAudioCard({
  required String name,
  required bool barColor,
  // ... other parameters
}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: barColor ? Colors.red : Colors.grey,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        CircleAvatar(
          child: Text(name[0]),
        ),
        Text(name),
        if (barColor) AudioWaveIndicator(),
      ],
    ),
  );
}
```

### Custom MiniCard
```dart
Widget myCustomMiniCard({
  required String initials,
  required String name,
  // ... other parameters
}) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Text(initials, style: TextStyle(fontSize: 20)),
        Text(name, style: TextStyle(fontSize: 12)),
        Row(
          children: [
            if (showVideoIcon) Icon(Icons.videocam_off),
            if (showAudioIcon) Icon(Icons.mic_off),
          ],
        ),
      ],
    ),
  );
}
```

## When Custom Builders Are Used

- **VideoCard**: For participants with active video streams
- **AudioCard**: For participants with audio only (no video)  
- **MiniCard**: For inactive participants (no audio or video)

## Parameters Passed to Builders

### VideoCard Parameters
- `participant`: The participant object with all participant data
- `stream`: The video stream object containing the MediaStream
- `width`/`height`: Dimensions for the video card
- `showControls`: Whether to show control overlays
- `showInfo`: Whether to show participant information
- `doMirror`: Whether to mirror the video (for local video)
- `parameters`: Access to all MediaSFU parameters

### AudioCard Parameters  
- `name`: Participant's display name
- `barColor`: Audio activity indicator (true = speaking)
- `textColor`: Recommended text color
- `parameters`: Access to all MediaSFU parameters

### MiniCard Parameters
- `initials`: Participant's initials for avatar
- `name`: Participant's display name
- `showVideoIcon`/`showAudioIcon`: Whether to show media status icons
- `parameters`: Access to all MediaSFU parameters

## Best Practices

1. **Maintain Aspect Ratios**: Respect the `width` and `height` parameters for VideoCard
2. **Handle Null Values**: Always check for null/optional parameters
3. **Performance**: Keep custom builders lightweight for smooth scrolling
4. **Accessibility**: Include proper accessibility labels and semantics
5. **Responsiveness**: Design for different screen sizes and orientations

## Complete Example

See `example/lib/custom_builders_example.dart` for a complete implementation showing all three custom builders with advanced styling and animations.

## Migration from Default Components

If you're migrating from default components:

1. Identify which visual aspects you want to customize
2. Create custom builder functions with your desired styling
3. Pass them to `MediasfuGenericOptions`
4. Test with different participant states (video on/off, audio on/off, inactive)

The custom builders provide complete flexibility while maintaining integration with the MediaSFU SDK's participant management and media handling systems.
