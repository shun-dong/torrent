# Command line tutorial

Some developers like using the command line extensively. Godot is designed to be friendly to them, so here are the steps for working entirely from the command line. Given the engine relies on almost no external libraries, initialization times are pretty fast, making it suitable for this workflow.

> **Note:** On Windows and Linux, you can run a Godot binary in a terminal by specifying its relative or absolute path.
>
> On macOS, the process is different due to Godot being contained within a `.app` bundle (which is a *folder*, not a file). To run a Godot binary from a terminal on macOS, you have to `cd` to the folder where the Godot application bundle is located, then run `Godot.app/Contents/MacOS/Godot` followed by any command line arguments. If you've renamed the application bundle from `Godot` to another name, make sure to edit this command line accordingly.

## Command line reference

**Legend**

- **(release)** Available in editor builds, debug export templates and release export templates.
- **(debug)** Available in editor builds and debug export templates only.
- **(extended)** Only available in editor builds, and export templates compiled with `disable_path_overrides=false`.
- **(editor)** Only available in editor builds.

Note that unknown command line arguments have no effect whatsoever. The engine will **not** warn you when using a command line argument that doesn't exist with a given build type.

### General options

| Command           | Description                                                  | Availability |
| ----------------- | ------------------------------------------------------------ | ------------ |
| `-h`, `--help`    | Display the list of command line options.                    | (release)    |
| `--version`       | Display the version string.                                  | (release)    |
| `-v`, `--verbose` | Use verbose stdout mode.                                     | (release)    |
| `-q`, `--quiet`   | Quiet mode, silences stdout messages. Errors are still displayed. | (release)    |
| `--no-header`     | Do not print engine version and rendering method header on startup. | (release)    |

### Run options

| Command                           | Description                                                  | Availability |
| --------------------------------- | ------------------------------------------------------------ | ------------ |
| `--`, `++`                        | Separator for user-provided arguments. Following arguments are not used by the engine, but can be read from `OS.get_cmdline_user_args()`. | (release)    |
| `-e`, `--editor`                  | Start the editor instead of running the scene.               | (editor)     |
| `-p`, `--project-manager`         | Start the Project Manager, even if a project is auto-detected. | (editor)     |
| `--recovery-mode`                 | Start the editor in recovery mode, which disables features that can typically cause startup crashes, such as tool scripts, editor plugins, GDExtension addons, and others. | (editor)     |
| `--debug-server <uri>`            | Start the editor debug server (`<protocol>://<host/IP>[:<port>]`, e.g. `tcp://127.0.0.1:6007`) | (editor)     |
| `--dap-port <port>`               | Use the specified port for the GDScript Debug Adapter Protocol. Recommended port range `[1024, 49151]`. | (editor)     |
| `--lsp-port <port>`               | Use the specified port for the GDScript Language Server Protocol. Recommended port range `[1024, 49151]`. | (editor)     |
| `--quit`                          | Quit after the first iteration.                              | (release)    |
| `--quit-after`                    | Quit after the given number of iterations. Set to 0 to disable. | (release)    |
| `-l`, `--language <locale>`       | Use a specific locale. `<locale>` follows the format `language_Script_COUNTRY_VARIANT` where language is a 2 or 3-letter language code in lowercase and the rest is optional. See [doc_locales] for more details. | (release)    |
| `--path <directory>`              | Path to a project (`<directory>` must contain a "project.godot" file). | (extended)   |
| `--scene <path>`                  | Path or UID of a scene in the project that should be started. | (extended)   |
| `--main-pack <file>`              | Path to a pack (.pck) file to load.                          | (extended)   |
| `--render-thread <mode>`          | Render thread mode ("unsafe", "safe", "separate"). See [Thread Model](class_ProjectSettings_property_rendering/driver/threads/thread_model) for more details. | (release)    |
| `--remote-fs <address>`           | Remote filesystem (`<host/IP>[:<port>]` address).            | (release)    |
| `--remote-fs-password <password>` | Password for remote filesystem.                              | (release)    |
| `--audio-driver <driver>`         | Audio driver. Use `--help` first to display the list of available drivers. | (release)    |
| `--display-driver <driver>`       | Display driver (and rendering driver). Use `--help` first to display the list of available drivers. | (release)    |
| `--audio-output-latency <ms>`     | Override audio output latency in milliseconds (default is 15 ms). Lower values make sound playback more reactive but increase CPU usage, and may result in audio cracking if the CPU can't keep up. | (release)    |
| `--rendering-method <renderer>`   | Renderer name. Requires driver support.                      | (release)    |
| `--rendering-driver <driver>`     | Rendering driver (depends on display driver). Use `--help` first to display the list of available drivers. | (release)    |
| `--gpu-index <device_index>`      | Use a specific GPU (run with `--verbose` to get available device list). | (release)    |
| `--text-driver <driver>`          | Text driver (Fonts, BiDi, shaping).                          | (release)    |
| `--tablet-driver <driver>`        | Pen tablet input driver.                                     | (release)    |
| `--headless`                      | Enable headless mode (`--display-driver headless --audio-driver Dummy`). Useful for servers and with `--script`. | (release)    |
| `--log-file`                      | Write output/error log to the specified path instead of the default location defined by the project. `<file>` path should be absolute or relative to the project directory. | (release)    |
| `--write-movie <file>`            | Run the engine in a way that a movie is written (usually with .avi or .png extension). `--fixed-fps` is forced when enabled, but can be used to change movie FPS. `--disable-vsync` can speed up movie writing but makes interaction more difficult. `--quit-after` can be used to specify the number of frames to write. | (release)    |

### Display options

| Command                  | Description                                                  | Availability |
| ------------------------ | ------------------------------------------------------------ | ------------ |
| `-f`, `--fullscreen`     | Request fullscreen mode.                                     | (release)    |
| `-m`, `--maximized`      | Request a maximized window.                                  | (release)    |
| `-w`, `--windowed`       | Request windowed mode.                                       | (release)    |
| `-t`, `--always-on-top`  | Request an always-on-top window.                             | (release)    |
| `--resolution <W>x<H>`   | Request window resolution.                                   | (release)    |
| `--position <X>,<Y>`     | Request window position.                                     | (release)    |
| `--screen <N>`           | Request window screen.                                       | (release)    |
| `--single-window`        | Use a single window (no separate subwindows).                | (release)    |
| `--xr-mode <mode>`       | Select XR mode ("default", "off", "on").                     | (release)    |
| `--wid <window_id>`      | Request parented to window.                                  | (release)    |
| `--accessibility <mode>` | Select accessibility mode ["auto" (when screen reader is running, default), "always", "disabled"]. | (release)    |

### Debug options

| Command                       | Description                                                  | Availability |
| ----------------------------- | ------------------------------------------------------------ | ------------ |
| `-d`, `--debug`               | Debug (local stdout debugger).                               | (release)    |
| `-b`, `--breakpoints`         | Breakpoint list as source::line comma-separated pairs, no spaces (use `%20` instead). | (release)    |
| `--ignore-error-breaks`       | If debugger is connected, prevents sending error breakpoints. | (release)    |
| `--profiling`                 | Enable profiling in the script debugger.                     | (release)    |
| `--gpu-profile`               | Show a GPU profile of the tasks that took the most time during frame rendering. | (release)    |
| `--gpu-validation`            | Enable graphics API [validation layers](doc_vulkan_validation_layers) for debugging. | (release)    |
| `--gpu-abort`                 | Abort on GPU errors (usually validation layer errors), may help see the problem if your system freezes. | (debug)      |
| `--generate-spirv-debug-info` | Generate SPIR-V debug information. This allows source-level shader debugging with RenderDoc. | (debug)      |
| `--extra-gpu-memory-tracking` | Enables additional memory tracking (see class reference for `RenderingDevice.get_driver_and_device_memory_report()` and linked methods). Currently only implemented for Vulkan. Enabling this feature may cause crashes on some systems due to buggy drivers or bugs in the Vulkan Loader. See https://github.com/godotengine/godot/issues/95967 | (debug)      |
| `--accurate-breadcrumbs`      | Force barriers between breadcrumbs. Useful for narrowing down a command causing GPU resets. Currently only implemented for Vulkan. | (debug)      |
| `--remote-debug <uri>`        | Remote debug (`<protocol>://<host/IP>[:<port>]`, e.g. `tcp://127.0.0.1:6007`). | (release)    |
| `--single-threaded-scene`     | Scene tree runs in single-threaded mode. Sub-thread groups are disabled and run on the main thread. | (release)    |
| `--debug-collisions`          | Show collision shapes when running the scene.                | (debug)      |
| `--debug-paths`               | Show path lines when running the scene.                      | (debug)      |
| `--debug-navigation`          | Show navigation polygons when running the scene.             | (debug)      |
| `--debug-avoidance`           | Show navigation avoidance debug visuals when running the scene. | (debug)      |
| `--debug-stringnames`         | Print all StringName allocations to stdout when the engine quits. | (debug)      |
| `--debug-canvas-item-redraw`  | Display a rectangle each time a canvas item requests a redraw (useful to troubleshoot low processor mode). | (debug)      |
| `--max-fps <fps>`             | Set a maximum number of frames per second rendered (can be used to limit power usage). A value of 0 results in unlimited framerate. | (release)    |
| `--frame-delay <ms>`          | Simulate high CPU load (delay each frame by <ms> milliseconds). Do not use as a FPS limiter; use `--max-fps` instead. | (release)    |
| `--time-scale <scale>`        | Force time scale (higher values are faster, 1.0 is normal speed). | (release)    |
| `--disable-vsync`             | Forces disabling of vertical synchronization, even if enabled in the project settings. Does not override driver-level V-Sync enforcement. | (release)    |
| `--disable-render-loop`       | Disable render loop so rendering only occurs when called explicitly from script. | (release)    |
| `--disable-crash-handler`     | Disable crash handler when supported by the platform code.   | (release)    |
| `--fixed-fps <fps>`           | Force a fixed number of frames per second. This setting disables real-time synchronization. | (release)    |
| `--delta-smoothing <enable>`  | Enable or disable frame delta smoothing ("enable", "disable"). | (release)    |
| `--print-fps`                 | Print the frames per second to the stdout.                   | (release)    |
| `--editor-pseudolocalization` | Enable pseudolocalization for the editor and the project manager. | (editor)     |

### Standalone tools

| Command                                                      | Description                                                  | Availability |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------ |
| `-s`, `--script <script>`                                    | Run a script. `<script>` must be a resource path relative to the project (`myscript.gd` will be interpreted as `res://my_script.gd`) or an absolute filesystem path (for example, on Windows: `C:/tmp/my_script.gd`). | (extended)   |
| `--main-loop <main_loop_name>`                               | Run a MainLoop specified by its global class name.           | (extended)   |
| `--check-only`                                               | Only parse for errors and quit (use with `--script`).        | (extended)   |
| `--import`                                                   | Starts the editor, waits for any resources to be imported, and then quits. Implies `--editor` and `--quit`. | (editor)     |
| `--export-release <preset> <path>`                           | Export the project in release mode using the given preset and output path. The preset name should match one defined in "export_presets.cfg". `<path>` should be absolute or relative to the project directory, and include the filename for the binary (e.g. "builds/game.exe"). The target directory must exist. | (editor)     |
| `--export-debug <preset> <path>`                             | Like `--export-release`, but use debug template. Implies `--import`. | (editor)     |
| `--export-pack <preset> <path>`                              | Like `--export-release`, but only export the game pack for the given preset. The `<path>` extension determines whether it will be in PCK or ZIP format. Implies `--import`. | (editor)     |
| `--export-patch <preset> <path>`                             | Export pack with changed files only. See `--export-pack` description for other considerations. | (editor)     |
| `--patches <paths>`                                          | List of patches to use with `--export-patch`. The list is comma-separated. | (editor)     |
| `--install-android-build-template`                           | Install the Android build template. Used in conjunction with `--export-release` or `--export-debug`. | (editor)     |
| `--convert-3to4 [<max_file_kb>] [<max_line_size>]`           | Convert project from Godot 3.x to Godot 4.x.                 | (editor)     |
| `--validate-conversion-3to4 [<max_file_kb>] [<max_line_size>]` | Show what elements will be renamed when converting project from Godot 3.x to Godot 4.x. | (editor)     |
| `--doctool [<path>]`                                         | Dump the engine API reference to the given `<path>` in XML format, merging if existing files are found. | (editor)     |
| `--no-docbase`                                               | Disallow dumping the base types (used with `--doctool`).     | (editor)     |
| `--gdextension-docs`                                         | Rather than dumping the engine API, generate API reference from all the GDExtensions loaded in the current project (used with `--doctool`). | (editor)     |
| `--gdscript-docs <path>`                                     | Rather than dumping the engine API, generate API reference from the inline documentation in the GDScript files found in `<path>` (used with `--doctool`). | (editor)     |
| `--build-solutions`                                          | Build the scripting solutions (e.g. for C# projects). Implies `--editor` and requires a valid project to edit. | (editor)     |
| `--dump-gdextension-interface`                               | Generate GDExtension header file "gdextension_interface.h" in the current folder. This file is the base file required to implement a GDExtension. | (editor)     |
| `--dump-gdextension-interface-json`                          | Generate a JSON dump of the GDExtension interface named "gdextension_interface.json" in the current folder. | (editor)     |
| `--dump-extension-api`                                       | Generate JSON dump of the Godot API for GDExtension bindings named "extension_api.json" in the current folder. | (editor)     |
| `--dump-extension-api-with-docs`                             | Generate JSON dump of the Godot API like the previous option, but including documentation. | (editor)     |
| `--validate-extension-api <path>`                            | Validate an extension API file dumped (with the option above) from a previous version of the engine to ensure API compatibility. If incompatibilities or errors are detected, the return code will be non-zero. | (editor)     |
| `--benchmark`                                                | Benchmark the run time and print it to console.              | (editor)     |
| `--benchmark-file <path>`                                    | Benchmark the run time and save it to a given file in JSON format. The path should be absolute. | (editor)     |
| `--test [--help]`                                            | Run [unit tests](doc_unit_testing) (requires compiling the engine with `tests=yes`). Use `--test --help` for more information. | (editor)     |

## Path

It is recommended to place your Godot editor binary in your `PATH` environment variable, so it can be executed easily from any place by typing `godot`. You can do so on Linux by placing the Godot binary in `/usr/local/bin` and making sure it is called `godot` (case-sensitive).

To achieve this on Windows or macOS easily, you can install Godot using [Scoop](https://scoop.sh) (on Windows) or [Homebrew](https://brew.sh) (on macOS). This will automatically make the copy of Godot installed available in the `PATH`:

**Windows:**

```sh
# Add "Extras" bucket
scoop bucket add extras

# Standard editor:
scoop install godot

# Editor with C# support (will be available as `godot-mono` in `PATH`):
scoop install godot-mono
```

**macOS:**

```sh
# Standard editor:
brew install godot

# Editor with C# support (will be available as `godot-mono` in `PATH`):
brew install godot-mono
```

## Setting the project path

Depending on where your Godot binary is located and what your current working directory is, you may need to set the path to your project for any of the following commands to work correctly.

When running the editor, this can be done by giving the path to the `project.godot` file of your project as either the first argument, like this:

```
godot path_to_your_project/project.godot [other] [commands] [and] [args]
```

For all commands, this can be done by using the `--path` argument:

```
godot --path path_to_your_project [other] [commands] [and] [args]
```

For example, the full command for exporting your game (as explained below) might look like this:

```
godot --headless --path path_to_your_project --export-release my_export_preset_name game.exe
```

When starting from a subdirectory of your project, use the `--upwards` argument for Godot to automatically find the `project.godot` file by recursively searching the parent directories.

For example, running a scene (as explained below) nested in a subdirectory might look like this when your working directory is in the same path:

```
godot --upwards nested_scene.tscn
```

## Creating a project

Creating a project from the command line can be done by navigating the shell to the desired place and making a `project.godot` file.

```
mkdir newgame
cd newgame
touch project.godot
```

The project can now be opened with Godot.

## Running the editor

Running the editor is done by executing Godot with the `-e` flag. This must be done from within the project directory or by setting the project path as explained above, otherwise the command is ignored and the Project Manager appears.

```
godot -e
```

When passing in the full path to the `project.godot` file, the `-e` flag may be omitted.

If a scene has been created and saved, it can be edited later by running the same code with that scene as argument.

```
godot -e scene.tscn
```

## Erasing a scene

Godot is friends with your filesystem and will not create extra metadata files. Use `rm` to erase a scene file. Make sure nothing references that scene. Otherwise, an error will be thrown upon opening the project.

```
rm scene.tscn
```

## Running the game

To run the game, execute Godot within the project directory or with the project path as explained above.

```
godot
```

Note that passing in the `project.godot` file will always run the editor instead of running the game.

When a specific scene needs to be tested, pass that scene to the command line.

```
godot scene.tscn
```

## Debugging

Catching errors in the command line can be a difficult task because they scroll quickly. For this, a command line debugger is provided by adding `-d`. It works for running either the game or a single scene.

```
godot -d
```

```
godot -d scene.tscn
```

## Exporting

Exporting the project from the command line is also supported. This is especially useful for continuous integration setups.

> **Note:** Using the `--headless` command line argument is **required** on platforms that do not have GPU access (such as continuous integration). On platforms with GPU access, `--headless` prevents a window from spawning while the project is exporting.

```
# `godot` must be a Godot editor binary, not an export template.
# Also, export templates must be installed for the editor
# (or a valid custom export template must be defined in the export preset).
godot --headless --export-release "Linux/X11" /var/builds/project
godot --headless --export-release Android /var/builds/project.apk
```

The preset name must match the name of an export preset defined in the project's `export_presets.cfg` file. If the preset name contains spaces or special characters (such as "Windows Desktop"), it must be surrounded with quotes.

To export a debug version of the game, use the `--export-debug` switch instead of `--export-release`. Their parameters and usage are the same.

To export only a PCK file, use the `--export-pack` option followed by the preset name and output path, with the file extension, instead of `--export-release` or `--export-debug`. The output path extension determines the package's format, either PCK or ZIP.

> **Warning:** When specifying a relative path as the path for `--export-release`, `--export-debug` or `--export-pack`, the path will be relative to the directory containing the `project.godot` file, **not** relative to the current working directory.

## Running a script

It is possible to run a `.gd` script from the command line. This feature is especially useful in large projects, e.g. for batch conversion of assets or custom import/export.

The script must inherit from `SceneTree` or `MainLoop`.

Here is an example `sayhello.gd`, showing how it works:

```gdscript
#!/usr/bin/env -S godot -s
extends SceneTree

func _init():
    print("Hello!")
    quit()
```

And how to run it:

```
# Prints "Hello!" to standard output.
godot -s sayhello.gd
```

If no `project.godot` exists at the path, current path is assumed to be the current working directory (unless `--path` is specified).

The script path will be interpreted as a resource path relative to the project, here `res://sayhello.gd`. You can also use an absolute filesystem path instead, which is useful if the script is located outside of the project directory.

The first line of `sayhello.gd` above is commonly referred to as a *shebang*. If the Godot binary is in your `PATH` as `godot`, it allows you to run the script as follows in modern Linux distributions, as well as macOS:

```
# Mark script as executable.
chmod +x sayhello.gd
# Prints "Hello!" to standard output.
./sayhello.gd
```

If the above doesn't work in your current version of Linux or macOS, you can always have the shebang run Godot straight from where it is located as follows:

```
#!/usr/bin/godot -s
```