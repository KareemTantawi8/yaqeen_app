# just_audio_background — keep the Android MediaBrowserService and related classes
-keep class com.ryanheise.** { *; }

# just_audio — keep ExoPlayer classes used via reflection
-keep class com.google.android.exoplayer2.** { *; }
-keep interface com.google.android.exoplayer2.** { *; }

# flutter_local_notifications — keep notification receiver classes
-keep class com.dexterous.** { *; }
