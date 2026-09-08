# OkHttp probes these optional JVM TLS providers at runtime. They are not
# bundled or used by the Android app, so R8 can safely ignore their absence.
-dontwarn org.bouncycastle.jsse.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
