import 'package:flutter/widgets.dart';

import '../components/display_components/alert_component.dart'
    show AlertComponentOptions;
import '../components/display_components/audio_grid.dart'
    show AudioGridOptions;
import '../components/display_components/control_buttons_component.dart'
    show ControlButtonsComponentOptions;
import '../components/display_components/control_buttons_alt_component.dart'
    show ControlButtonsAltComponentOptions;
import '../components/display_components/control_buttons_component_touch.dart'
    show ControlButtonsComponentTouchOptions;
import '../components/display_components/flexible_grid.dart'
    show FlexibleGridOptions;
import '../components/display_components/flexible_video.dart'
    show FlexibleVideoOptions;
import '../components/display_components/loading_modal.dart'
    show LoadingModalOptions;
import '../components/display_components/main_aspect_component.dart'
    show MainAspectComponentOptions;
import '../components/display_components/main_container_component.dart'
    show MainContainerComponentOptions;
import '../components/display_components/main_grid_component.dart'
    show MainGridComponentOptions;
import '../components/display_components/main_screen_component.dart'
    show MainScreenComponentOptions;
import '../components/display_components/meeting_progress_timer.dart'
    show MeetingProgressTimerOptions;
import '../components/display_components/mini_audio.dart' show MiniAudioOptions;
import '../components/display_components/other_grid_component.dart'
    show OtherGridComponentOptions;
import '../components/display_components/pagination.dart'
    show PaginationOptions;
import '../components/display_components/sub_aspect_component.dart'
    show SubAspectComponentOptions;
import '../components/event_settings_components/event_settings_modal.dart'
    show EventSettingsModalOptions;
import '../components/menu_components/custom_buttons.dart'
    show CustomButtonsOptions;
import '../components/menu_components/menu_modal.dart' show MenuModalOptions;
import '../components/message_components/messages_modal.dart'
    show MessagesModalOptions;
import '../components/misc_components/confirm_here_modal.dart'
    show ConfirmHereModalOptions;
import '../components/misc_components/prejoin_page.dart'
    show PreJoinPageOptions;
import '../components/misc_components/share_event_modal.dart'
    show ShareEventModalOptions;
import '../components/misc_components/welcome_page.dart'
    show WelcomePageOptions;
import '../components/participants_components/participants_modal.dart'
    show ParticipantsModalOptions;
import '../components/polls_components/poll_modal.dart' show PollModalOptions;
import '../components/recording_components/recording_modal.dart'
    show RecordingModalOptions;
import '../components/requests_components/requests_modal.dart'
    show RequestsModalOptions;
import '../components/waiting_components/waiting_modal.dart'
    show WaitingRoomModalOptions;
import '../components/co_host_components/co_host_modal.dart'
    show CoHostModalOptions;
import '../components/media_settings_components/media_settings_modal.dart'
    show MediaSettingsModalOptions;
import '../components/display_settings_components/display_settings_modal.dart'
    show DisplaySettingsModalOptions;
import '../components/exit_components/confirm_exit_modal.dart'
    show ConfirmExitModalOptions;
import '../components/breakout_components/breakout_rooms_modal.dart'
    show BreakoutRoomsModalOptions;
import '../consumers/add_videos_grid.dart' show AddVideosGridType;
import '../consumers/consumer_resume.dart' show ConsumerResumeType;
import '../consumers/prepopulate_user_media.dart'
  show PrepopulateUserMediaType;
import '../methods/utils/mini_audio_player/mini_audio_player.dart'
    show MiniAudioPlayerOptions;

/// Signature for the default builder used by UI overrides.
typedef DefaultComponentBuilder<TOptions> = Widget Function(
  BuildContext context,
  TOptions options,
);

/// Signature for wrap-based overrides that receive the default builder.
typedef OverrideRenderBuilder<TOptions> = Widget Function(
  BuildContext context,
  TOptions options,
  DefaultComponentBuilder<TOptions> defaultBuilder,
);

/// Represents a component override with optional replacement or wrapper builders.
class ComponentOverride<TOptions> {
  final DefaultComponentBuilder<TOptions>? component;
  final OverrideRenderBuilder<TOptions>? render;

  const ComponentOverride({
    this.component,
    this.render,
  });
}

/// Represents a function override that can either replace or wrap the default implementation.
class FunctionOverride<TFunction extends Function> {
  final TFunction? implementation;
  final TFunction Function(TFunction original)? wrap;

  const FunctionOverride({
    this.implementation,
    this.wrap,
  });
}

/// Applies a component override to the provided default builder.
DefaultComponentBuilder<TOptions> withOverride<TOptions>({
  ComponentOverride<TOptions>? override,
  required DefaultComponentBuilder<TOptions> baseBuilder,
}) {
  if (override == null) {
    return baseBuilder;
  }

  if (override.component != null) {
    return override.component!;
  }

  if (override.render != null) {
    return (context, options) =>
        override.render!(context, options, baseBuilder);
  }

  return baseBuilder;
}

/// Applies a function override to the provided default implementation.
TFunction withFunctionOverride<TFunction extends Function>({
  required TFunction base,
  FunctionOverride<TFunction>? override,
}) {
  if (override == null) {
    return base;
  }

  if (override.implementation != null) {
    return override.implementation!;
  }

  if (override.wrap != null) {
    return override.wrap!(base);
  }

  return base;
}

/// Styling hooks for wrapping the primary container across MediaSFU experiences.
class ContainerStyleOptions {
  final Color? backgroundColor;
  final double? widthFraction;
  final double? heightFraction;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;
  final Clip? clipBehavior;

  const ContainerStyleOptions({
    this.backgroundColor,
    this.widthFraction,
    this.heightFraction,
    this.margin,
    this.padding,
    this.decoration,
    this.alignment,
    this.clipBehavior,
  });
}

/// Aggregates all supported UI override slots for the Flutter SDK.
class MediasfuUICustomOverrides {
  final ComponentOverride<MainContainerComponentOptions>? mainContainer;
  final ComponentOverride<MainAspectComponentOptions>? mainAspect;
  final ComponentOverride<MainScreenComponentOptions>? mainScreen;
  final ComponentOverride<MainGridComponentOptions>? mainGrid;
  final ComponentOverride<SubAspectComponentOptions>? subAspect;
  final ComponentOverride<OtherGridComponentOptions>? otherGrid;
  final ComponentOverride<FlexibleGridOptions>? flexibleGrid;
  final ComponentOverride<FlexibleGridOptions>? flexibleGridAlt;
  final ComponentOverride<FlexibleVideoOptions>? flexibleVideo;
  final ComponentOverride<AudioGridOptions>? audioGrid;
  final ComponentOverride<PaginationOptions>? pagination;
  final ComponentOverride<ControlButtonsComponentOptions>? controlButtons;
  final ComponentOverride<ControlButtonsAltComponentOptions>? controlButtonsAlt;
  final ComponentOverride<ControlButtonsComponentTouchOptions>?
      controlButtonsTouch;
  final ComponentOverride<MeetingProgressTimerOptions>? meetingProgressTimer;
  final ComponentOverride<MiniAudioOptions>? miniAudio;
  final ComponentOverride<MiniAudioPlayerOptions>? miniAudioPlayer;
  final ComponentOverride<LoadingModalOptions>? loadingModal;
  final ComponentOverride<AlertComponentOptions>? alert;
  final ComponentOverride<MenuModalOptions>? menuModal;
  final ComponentOverride<CustomButtonsOptions>? customMenuButtonsRenderer;
  final ComponentOverride<EventSettingsModalOptions>? eventSettingsModal;
  final ComponentOverride<RequestsModalOptions>? requestsModal;
  final ComponentOverride<WaitingRoomModalOptions>? waitingRoomModal;
  final ComponentOverride<CoHostModalOptions>? coHostModal;
  final ComponentOverride<MediaSettingsModalOptions>? mediaSettingsModal;
  final ComponentOverride<ParticipantsModalOptions>? participantsModal;
  final ComponentOverride<MessagesModalOptions>? messagesModal;
  final ComponentOverride<DisplaySettingsModalOptions>? displaySettingsModal;
  final ComponentOverride<ConfirmExitModalOptions>? confirmExitModal;
  final ComponentOverride<ConfirmHereModalOptions>? confirmHereModal;
  final ComponentOverride<ShareEventModalOptions>? shareEventModal;
  final ComponentOverride<RecordingModalOptions>? recordingModal;
  final ComponentOverride<PollModalOptions>? pollModal;
  final ComponentOverride<BreakoutRoomsModalOptions>? breakoutRoomsModal;
  final ComponentOverride<PreJoinPageOptions>? preJoinPage;
  final ComponentOverride<WelcomePageOptions>? welcomePage;

  final FunctionOverride<ConsumerResumeType>? consumerResume;
  final FunctionOverride<AddVideosGridType>? addVideosGrid;
  final FunctionOverride<PrepopulateUserMediaType>? prepopulateUserMedia;

  const MediasfuUICustomOverrides({
    this.mainContainer,
    this.mainAspect,
    this.mainScreen,
    this.mainGrid,
    this.subAspect,
    this.otherGrid,
    this.flexibleGrid,
    this.flexibleGridAlt,
    this.flexibleVideo,
    this.audioGrid,
    this.pagination,
    this.controlButtons,
    this.controlButtonsAlt,
    this.controlButtonsTouch,
    this.meetingProgressTimer,
    this.miniAudio,
    this.miniAudioPlayer,
    this.loadingModal,
    this.alert,
    this.menuModal,
    this.customMenuButtonsRenderer,
    this.eventSettingsModal,
    this.requestsModal,
    this.waitingRoomModal,
    this.coHostModal,
    this.mediaSettingsModal,
    this.participantsModal,
    this.messagesModal,
    this.displaySettingsModal,
    this.confirmExitModal,
    this.confirmHereModal,
    this.shareEventModal,
    this.recordingModal,
    this.pollModal,
    this.breakoutRoomsModal,
    this.preJoinPage,
    this.welcomePage,
    this.consumerResume,
    this.addVideosGrid,
    this.prepopulateUserMedia,
  });

  const MediasfuUICustomOverrides.empty()
      : this();
}
