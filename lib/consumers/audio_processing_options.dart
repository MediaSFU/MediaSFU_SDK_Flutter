class AudioProcessingOptions {
  final bool? echoCancellation;
  final bool? noiseSuppression;
  final bool? autoGainControl;

  const AudioProcessingOptions({
    this.echoCancellation,
    this.noiseSuppression,
    this.autoGainControl,
  });

  Map<String, dynamic> toMap() => {
    if (echoCancellation != null) 'echoCancellation': echoCancellation,
    if (noiseSuppression != null) 'noiseSuppression': noiseSuppression,
    if (autoGainControl != null) 'autoGainControl': autoGainControl,
  };
}
