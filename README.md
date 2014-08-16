#native_extension_with_build_tools
==========

Example of the `build script` for the native extension (C++) for the Dart VM with the usage of `build_tools` and `ccompilers`.

Version: 0.0.11

Makefile with rules:

```dart
import "dart:io";
import "package:build_tools/build_shell.dart";
import "package:build_tools/build_tools.dart";
import "package:ccompilers/ccompilers.dart";
import "package:file_utils/file_utils.dart";
import "package:patsubst/patsubst.dart";

void main(List<String> args) {
  const String PROJECT_NAME = "sample_extension";
  const String LIBNAME_LINUX = "lib$PROJECT_NAME.so";
  const String LIBNAME_MACOS = "lib$PROJECT_NAME.dylib";
  const String LIBNAME_WINDOWS = "$PROJECT_NAME.dll";

  // Determine operating system
  var os = Platform.operatingSystem;

  // Setup Dart SDK bitness for native extension
  var bits = DartSDK.getVmBits();

  // Compiler options
  var compilerDefine = {};
  var compilerInclude = ['$DART_SDK/bin', '$DART_SDK/include'];

  // Linker options
  var linkerLibpath = <String>[];

  // OS dependent parameters
  var libname = "";
  var objExtension = "";
  switch (os) {
    case "linux":
      libname = LIBNAME_LINUX;
      objExtension = ".o";
      break;
    case "macos":
      libname = LIBNAME_MACOS;
      objExtension = ".o";
      break;
    case "windows":
      libname = LIBNAME_WINDOWS;
      objExtension = ".obj";
      break;
    default:
      print("Unsupported operating system: $os");
      exit(-1);
  }

  // http://dartbug.com/20119
  var bug20119 = Platform.script;

  // Set working directory
  FileUtils.chdir("../lib/src");

  // C++ files
  var cppFiles = FileUtils.glob("*.cc");
  if (os != "windows") {
    cppFiles = FileUtils.exclude(cppFiles, "${PROJECT_NAME}_dllmain_win.cc");
  }

  // Object files
  var objFiles = patsubst("%.cc", "%${objExtension}").replaceAll(cppFiles);

  // Makefile
  // Target: default
  target("default", ["build"], null, description: "Build and clean.");

  // Target: build
  target("build", ["clean_all", "compile_link", "clean"], (Target t, Map args) {
    print("The ${t.name} successful.");
  }, description: "Build '$PROJECT_NAME'.");

  // Target: compile_link
  target("compile_link", [libname], (Target t, Map args) {
    print("The ${t.name} successful.");
  }, description: "Compile and link '$PROJECT_NAME'.");

  // Target: clean
  target("clean", [], (Target t, Map args) {
    FileUtils.rm(["*.exp", "*.lib", "*.o", "*.obj"], force: true);
    print("The ${t.name} successful.");
  }, description: "Deletes all intermediate files.", reusable: true);

  // Target: clean_all
  target("clean_all", ["clean"], (Target t, Map args) {
    FileUtils.rm([libname], force: true);
    print("The ${t.name} successful.");
  }, description: "Deletes all intermediate and output files.", reusable: true);

  // Compile on Posix
  rule("%.o", ["%.cc"], (Target t, Map args) {
    var compiler = new GnuCppCompiler(bits);
    var args = ['-fPIC', '-Wall'];
    return compiler.compile(t.sources, arguments: args, define: compilerDefine,
        include: compilerInclude, output: t.name).exitCode;
  });

  // Compile on Windows
  rule("%.obj", ["%.cc"], (Target t, Map args) {
    var compiler = new MsCppCompiler(bits);
    var define = new Map.from(compilerDefine);
    define["DART_SHARED_LIB"] = null;
    return compiler.compile(t.sources, define: compilerDefine, include:
        compilerInclude, output: t.name).exitCode;
  });

  // Link on Linux
  file(LIBNAME_LINUX, objFiles, (Target t, Map args) {
    var linker = new GnuLinker(bits);
    var args = ['-shared'];
    return linker.link(t.sources, arguments: args, libpaths: linkerLibpath,
        output: t.name).exitCode;
  });

  // Link on Macos
  file(LIBNAME_MACOS, objFiles, (Target t, Map args) {
    var linker = new GnuLinker(bits);
    var args = ['-dynamiclib', '-undefined', 'dynamic_lookup'];
    return linker.link(t.sources, arguments: args, libpaths: linkerLibpath,
        output: t.name).exitCode;
  });

  // Link on Windows
  file(LIBNAME_WINDOWS, objFiles, (Target t, Map args) {
    var linker = new MsLinker(bits);
    var args = ['/DLL', 'dart.lib'];
    var libpaths = new List.from(linkerLibpath);
    libpaths.add('$DART_SDK/bin');
    return linker.link(t.sources, arguments: args, output: t.name).exitCode;
  });

  new BuildShell().run(args).then((exitCode) => exit(exitCode));
}

```

Makefile without rules:

```dart
import "dart:io";
import "package:build_tools/build_shell.dart";
import "package:build_tools/build_tools.dart";
import "package:ccompilers/ccompilers.dart";
import "package:file_utils/file_utils.dart";

void main(List<String> args) {
  const String PROJECT_NAME = "sample_extension";
  const String LIBNAME_LINUX = "lib$PROJECT_NAME.so";
  const String LIBNAME_MACOS = "lib$PROJECT_NAME.dylib";
  const String LIBNAME_WINDOWS = "$PROJECT_NAME.dll";

  // Determine operating system
  var os = Platform.operatingSystem;

  // Setup Dart SDK bitness for native extension
  var bits = DartSDK.getVmBits();

  // Compiler options
  var compilerDefine = {};
  var compilerInclude = ['$DART_SDK/bin', '$DART_SDK/include'];

  // Linker options
  var linkerLibpath = <String>[];

  // OS dependent parameters
  var libname = "";
  switch (os) {
    case "linux":
      libname = LIBNAME_LINUX;
      break;
    case "macos":
      libname = LIBNAME_MACOS;
      break;
    case "windows":
      libname = LIBNAME_WINDOWS;
      break;
    default:
      print("Unsupported operating system: $os");
      exit(-1);
  }

  // http://dartbug.com/20119
  var bug20119 = Platform.script;

  // Set working directory
  FileUtils.chdir("../lib/src");

  // C++ files
  var cppFiles = FileUtils.glob("*.cc");
  if (os != "windows") {
    cppFiles = FileUtils.exclude(cppFiles, "${PROJECT_NAME}_dllmain_win.cc");
  }

  // Makefile
  // Target: default
  target("default", ["build"], null, description: "Build and clean.");

  // Target: build
  target("build", ["clean_all", "compile_link", "clean"], (Target t, Map args) {
    print("The ${t.name} successful.");
  }, description: "Build '$PROJECT_NAME'.");

  // Target: compile_link
  target("compile_link", [libname], (Target t, Map args) {
    print("The ${t.name} successful.");
  }, description: "Compile and link '$PROJECT_NAME'.");

  // Target: clean
  target("clean", [], (Target t, Map args) {
    FileUtils.rm(["*.exp", "*.lib", "*.o", "*.obj"], force: true);
    print("The ${t.name} successful.");
  }, description: "Deletes all intermediate files.", reusable: true);

  // Target: clean_all
  target("clean_all", ["clean"], (Target t, Map args) {
    FileUtils.rm([libname], force: true);
    print("The ${t.name} successful.");
  }, description: "Deletes all intermediate and output files.", reusable: true);

  // Compile on Posix
  file("$PROJECT_NAME.o", cppFiles, (Target t, Map args) {
    var compiler = new GnuCppCompiler(bits);
    var args = ['-fPIC', '-Wall'];
    return compiler.compile(t.sources, arguments: args, define: compilerDefine,
        include: compilerInclude, output: t.name).exitCode;
  });

  // Compile on Windows
  file("$PROJECT_NAME.obj", cppFiles, (Target t, Map args) {
    var compiler = new MsCppCompiler(bits);
    var define = new Map.from(compilerDefine);
    define["DART_SHARED_LIB"] = null;
    return compiler.compile(t.sources, define: compilerDefine, include:
        compilerInclude, output: t.name).exitCode;
  });

  // Link on Linux
  file(LIBNAME_LINUX, ["$PROJECT_NAME.o"], (Target t, Map args) {
    var linker = new GnuLinker(bits);
    var args = ['-shared'];
    return linker.link(t.sources, arguments: args, libpaths: linkerLibpath,
        output: t.name).exitCode;
  });

  // Link on Macos
  file(LIBNAME_MACOS, ["$PROJECT_NAME.o"], (Target t, Map args) {
    var linker = new GnuLinker(bits);
    var args = ['-dynamiclib', '-undefined', 'dynamic_lookup'];
    return linker.link(t.sources, arguments: args, libpaths: linkerLibpath,
        output: t.name).exitCode;
  });

  // Link on Windows
  file(LIBNAME_WINDOWS, ["$PROJECT_NAME.obj"], (Target t, Map args) {
    var linker = new MsLinker(bits);
    var args = ['/DLL', 'dart.lib'];
    var libpaths = new List.from(linkerLibpath);
    libpaths.add('$DART_SDK/bin');
    return linker.link(t.sources, arguments: args, output: t.name).exitCode;
  });

  new BuildShell().run(args).then((exitCode) => exit(exitCode));
}

```
