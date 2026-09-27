// The Google services plugin turns android/app/google-services.json into the
// string resources the Firebase SDKs read when a FirebaseApp is created.
//
// It is declared here with `apply false` so the version is resolved once for the
// whole build, and applied in android/app/build.gradle.kts, which is the module
// google-services.json belongs to. Applying it here as well would configure the
// root project as an Android application, which it is not.
//
// The Firebase Android SDKs themselves are brought in by the firebase_core and
// firebase_messaging Flutter plugins, which pin versions that match each other,
// so no Firebase BoM or dependency list is needed here.
plugins {
    id("com.google.gms.google-services") version "4.5.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
