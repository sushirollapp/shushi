# ============================================
# SUSHI ROLL RUSH - ProGuard Rules
# ============================================
# These rules are required for R8 (Android's code shrinker) to work
# correctly with Flutter release builds.
# ============================================

# ============================================
# FLUTTER RULES
# ============================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ============================================
# PLAY CORE / DEFERRED COMPONENTS
# ============================================
# Flutter may reference Google Play Core classes for deferred components
# (dynamic feature modules). If the app doesn't use this feature,
# R8 will fail because it can't find these classes.
# These -dontwarn rules tell R8 to ignore the missing classes.
# ============================================

# Play Core library classes
-dontwarn com.google.android.play.core.**

# Split Install classes (deferred components)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# App Update classes
-dontwarn com.google.android.play.core.appupdate.**

# Asset Delivery classes
-dontwarn com.google.android.play.core.assetpacks.**

# Review classes
-dontwarn com.google.android.play.core.review.**

# Common classes
-dontwarn com.google.android.play.core.common.**
-dontwarn com.google.android.play.core.listener.**

# ============================================
# FLAME GAME ENGINE
# ============================================
-keep class com.flame.** { *; }

# ============================================
# AUDIOPLAYERS
# ============================================
-keep class xyz.luan.audioplayers.** { *; }

# ============================================
# GENERAL ANDROID RULES
# ============================================
# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ============================================
# REMOVE LOGGING IN RELEASE
# ============================================
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
}

# ============================================
# OPTIMIZATION FLAGS
# ============================================
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose
