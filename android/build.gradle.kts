import org.gradle.api.tasks.compile.JavaCompile

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

// FIX: Force JAVA 17 + KOTLIN 2.0 + COMPILE SDK 36 for ALL plugins (file_picker, etc)
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            try {
                val androidExt = ext as com.android.build.api.dsl.ApplicationExtension
                androidExt.compileSdk = 36
                androidExt.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                    isCoreLibraryDesugaringEnabled = true
                }
            } catch (e: Exception) {
                try {
                    val androidExt2 = ext as com.android.build.api.dsl.LibraryExtension
                    androidExt2.compileSdk = 36
                    androidExt2.compileOptions {
                        sourceCompatibility = JavaVersion.VERSION_17
                        targetCompatibility = JavaVersion.VERSION_17
                    }
                } catch (e2: Exception) {}
            }
        }
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                languageVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_0)
                apiVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_0)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}