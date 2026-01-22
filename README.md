# cmake-git-versioning

A CMake module for automatically generating version information from Git for C++
and C projects.

## Features

- Automatic extraction of version information from Git
- Support for C++ headers (`version.hpp`), C++20 modules (`version.cppm`), and C
  (`version.h`)
- Easy integration via CPM (CMake Package Manager)
- Extracts: Version, Pre-release information, Commit Hash, Branch, Commit Date

## Installation via CPM

Add the following to your `CMakeLists.txt`:

```cmake
include(cmake/CPM.cmake)

CPMAddPackage(
    NAME cmake-git-versioning
    GITHUB_REPOSITORY Katze719/cmake-git-versioning
    GIT_TAG main  # or a specific tag
)
```

## Usage

### For C++ Projects (Default)

```cmake
# After CPMAddPackage
include(cmake/cmake-git-versioning.cmake)

# Generate version.hpp (default)
generate_git_version()

# Add the generated directory to include paths
target_include_directories(your_target PRIVATE ${CMAKE_BINARY_DIR}/generated)

# Use in your code:
# #include "version.hpp"
# std::cout << version::VERSION << std::endl;
```

### For C++20 Modules

```cmake
# After CPMAddPackage
include(cmake/cmake-git-versioning.cmake)

# Generate version.cppm with CXX_MODULE option
generate_git_version(CXX_MODULE)

# Add the generated directory to module search paths
target_sources(your_target PRIVATE ${CMAKE_BINARY_DIR}/generated/version.cppm)

# Use in your code:
# import version;
# std::cout << version::VERSION << std::endl;
```

### For C Projects

```cmake
# After CPMAddPackage
include(cmake/cmake-git-versioning.cmake)

# Generate version.h with C_VERSION option
generate_git_version(C_VERSION)

# Add the generated directory to include paths
target_include_directories(your_target PRIVATE ${CMAKE_BINARY_DIR}/generated)

# Use in your code:
# #include "version.h"
# printf("Version: %s\n", VERSION_STRING);
```

### Advanced Options

```cmake
# Custom template file and output directory
generate_git_version(
    OUTPUT_DIR ${CMAKE_BINARY_DIR}/custom_version
    TEMPLATE_FILE ${CMAKE_SOURCE_DIR}/custom_version.hpp.in
    OUTPUT_FILE custom_version.hpp
)

# For C with custom options
generate_git_version(
    C_VERSION
    OUTPUT_DIR ${CMAKE_BINARY_DIR}/version_info
    OUTPUT_FILE my_version.h
)
```

### Using CMake Variables

The module also provides CMake variables that you can use directly in your
`CMakeLists.txt`:

```cmake
# After CPMAddPackage
include(cmake/cmake-git-versioning.cmake)

# Get git version info (sets CMake variables)
get_git_version_info()

# Use the variables in your CMake code
project(MyProject VERSION ${GIT_VERSION_MAJOR}.${GIT_VERSION_MINOR}.${GIT_VERSION_PATCH})

# Or use them in configure_file, message, etc.
message(STATUS "Building version: ${GIT_DESCRIBE}")
message(STATUS "Commit: ${GIT_COMMIT_HASH_SHORT}")
message(STATUS "Branch: ${GIT_BRANCH}")

# You can also use them in configure_file for custom templates
configure_file(
    ${CMAKE_SOURCE_DIR}/config.h.in
    ${CMAKE_BINARY_DIR}/config.h
    @ONLY
)
```

**Available CMake Variables:**

- `GIT_VERSION_MAJOR` - Major version number
- `GIT_VERSION_MINOR` - Minor version number
- `GIT_VERSION_PATCH` - Patch version number
- `GIT_DESCRIBE` - Full version string from git describe
- `GIT_COMMIT_HASH_SHORT` - Short commit hash
- `GIT_COMMIT_HASH_FULL` - Full commit hash
- `GIT_BRANCH` - Current branch name
- `GIT_COMMIT_DATE` - Commit date
- `GIT_TAG` - Latest tag (with 'v' prefix if present)
- `GIT_TAG_NO_V` - Latest tag without 'v' prefix
- `GIT_DESCRIBE_TAG` - Tag from git describe (with 'v' prefix if present)
- `GIT_DESCRIBE_TAG_NO_V` - Tag from git describe without 'v' prefix
- `GIT_COMMIT_COUNT` - Number of commits since the tag (0 if on tag)
- `GIT_DESCRIBE_HASH` - Commit hash from git describe
- `GIT_IS_DIRTY` - "true" if working directory has uncommitted changes, "false"
  otherwise
- `GIT_DIRTY_SUFFIX` - "-dirty" if dirty, empty string otherwise
- `GIT_VERSION_PRERELEASE` - Pre-release identifier (e.g., "alpha.1", "beta.2",
  "rc.1") or empty string
- `GIT_VERSION_PRERELEASE_TYPE` - Pre-release type (e.g., "alpha", "beta", "rc")
  or empty string
- `GIT_VERSION_PRERELEASE_NUMBER` - Pre-release number (e.g., "1", "2") or empty
  string

Note: `generate_git_version()` automatically calls `get_git_version_info()`, so
the variables are available after calling either function.

**Supported Tag Formats:**

- `v1.2.3` - Standard version
- `v1.2.3-alpha.1` - Pre-release version
- `v1.2.3-beta.2` - Pre-release version
- `v1.2.3-rc.1` - Release candidate
- `1.2.3-alpha.1` - Without 'v' prefix

## Generated Information

### C++ Header (version.hpp)

- `version::MAJOR`, `version::MINOR`, `version::PATCH` - Version numbers as
  `inline constexpr int`
- `version::VERSION` - Full version string (e.g., "v1.2.3" or
  "v1.2.3-5-gabc1234")
- `version::GIT_COMMIT_HASH_SHORT` - Short commit hash
- `version::GIT_COMMIT_HASH_FULL` - Full commit hash
- `version::GIT_BRANCH` - Current branch name
- `version::GIT_COMMIT_DATE` - Commit date
- `version::GIT_TAG` - Latest tag (with 'v' prefix if present)
- `version::GIT_TAG_NO_V` - Latest tag without 'v' prefix
- `version::GIT_DESCRIBE_TAG` - Tag from git describe (with 'v' prefix if
  present)
- `version::GIT_DESCRIBE_TAG_NO_V` - Tag from git describe without 'v' prefix
- `version::GIT_COMMIT_COUNT` - Number of commits since the tag (0 if on tag)
- `version::GIT_DESCRIBE_HASH` - Commit hash from git describe
- `version::GIT_IS_DIRTY` - `true` if working directory has uncommitted changes,
  `false` otherwise
- `version::GIT_DIRTY_SUFFIX` - "-dirty" if dirty, empty string otherwise
- `version::getVersionString()` - Helper function for version string
- `version::getFullVersionInfo()` - Helper function for full version info
- `version::buildGitDescribe()` - Helper function to build git describe string
  from components

### C++20 Module (version.cppm)

- `version::MAJOR`, `version::MINOR`, `version::PATCH` - Version numbers as
  `inline constexpr int`
- `version::PRERELEASE` - Pre-release identifier (e.g., "alpha.1", "beta.2") or
  empty string
- `version::PRERELEASE_TYPE` - Pre-release type (e.g., "alpha", "beta", "rc") or
  empty string
- `version::PRERELEASE_NUMBER` - Pre-release number (e.g., "1", "2") or empty
  string
- `version::VERSION` - Full version string (e.g., "v1.2.3" or
  "v1.2.3-5-gabc1234")
- `version::GIT_COMMIT_HASH_SHORT` - Short commit hash
- `version::GIT_COMMIT_HASH_FULL` - Full commit hash
- `version::GIT_BRANCH` - Current branch name
- `version::GIT_COMMIT_DATE` - Commit date
- `version::GIT_TAG` - Latest tag (with 'v' prefix if present)
- `version::GIT_TAG_NO_V` - Latest tag without 'v' prefix
- `version::GIT_DESCRIBE_TAG` - Tag from git describe (with 'v' prefix if
  present)
- `version::GIT_DESCRIBE_TAG_NO_V` - Tag from git describe without 'v' prefix
- `version::GIT_COMMIT_COUNT` - Number of commits since the tag (0 if on tag)
- `version::GIT_DESCRIBE_HASH` - Commit hash from git describe
- `version::GIT_IS_DIRTY` - `true` if working directory has uncommitted changes,
  `false` otherwise
- `version::GIT_DIRTY_SUFFIX` - "-dirty" if dirty, empty string otherwise
- `version::getVersionString()` - Exported helper function for version string
- `version::getFullVersionInfo()` - Exported helper function for full version
  info
- `version::buildGitDescribe()` - Exported helper function to build git describe
  string from components

### C (version.h)

- `VERSION_MAJOR`, `VERSION_MINOR`, `VERSION_PATCH` - Version numbers as
  `#define`
- `VERSION_PRERELEASE` - Pre-release identifier (e.g., "alpha.1", "beta.2") or
  empty string
- `VERSION_PRERELEASE_TYPE` - Pre-release type (e.g., "alpha", "beta", "rc") or
  empty string
- `VERSION_PRERELEASE_NUMBER` - Pre-release number (e.g., "1", "2") or empty
  string
- `VERSION_STRING` - Full version string
- `GIT_COMMIT_HASH_SHORT` - Short commit hash
- `GIT_COMMIT_HASH_FULL` - Full commit hash
- `GIT_BRANCH` - Current branch name
- `GIT_COMMIT_DATE` - Commit date
- `GIT_TAG` - Latest tag (with 'v' prefix if present)
- `GIT_TAG_NO_V` - Latest tag without 'v' prefix
- `GIT_DESCRIBE_TAG` - Tag from git describe (with 'v' prefix if present)
- `GIT_DESCRIBE_TAG_NO_V` - Tag from git describe without 'v' prefix
- `GIT_COMMIT_COUNT` - Number of commits since the tag (0 if on tag)
- `GIT_DESCRIBE_HASH` - Commit hash from git describe
- `GIT_IS_DIRTY` - 1 if working directory has uncommitted changes, 0 otherwise
- `GIT_DIRTY_SUFFIX` - "-dirty" if dirty, empty string otherwise

## Examples

### C++ Header Example

```cpp
#include "version.hpp"
#include <iostream>

int main() {
    std::cout << "Version: " << version::VERSION << std::endl;
    std::cout << "Full Info: " << version::getFullVersionInfo() << std::endl;
    std::cout << "Commit: " << version::GIT_COMMIT_HASH_SHORT << std::endl;
    
    // Build git describe from components
    std::cout << "Tag: " << version::GIT_TAG_NO_V << std::endl;
    std::cout << "Commits since tag: " << version::GIT_COMMIT_COUNT << std::endl;
    std::cout << "Built describe: " << version::buildGitDescribe() << std::endl;
    std::cout << "Is dirty: " << (version::GIT_IS_DIRTY ? "yes" : "no") << std::endl;
    return 0;
}
```

### C++20 Module Example

```cpp
import version;
import <iostream>;

int main() {
    std::cout << "Version: " << version::VERSION << std::endl;
    std::cout << "Full Info: " << version::getFullVersionInfo() << std::endl;
    std::cout << "Commit: " << version::GIT_COMMIT_HASH_SHORT << std::endl;
    return 0;
}
```

### C Example

```c
#include "version.h"
#include <stdio.h>

int main() {
    printf("Version: %s\n", VERSION_STRING);
    printf("Major: %d, Minor: %d, Patch: %d\n", 
           VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH);
    printf("Commit: %s\n", GIT_COMMIT_HASH_SHORT);
    return 0;
}
```

## Requirements

- CMake 3.10 or higher (3.28+ recommended for full C++20 module support)
- Git (for version generation)
- CPM

**Optional requirements:**

- C++20 compatible compiler (only required if using `CXX_MODULE` option)

## License

MIT License - see [LICENSE](LICENSE) file
