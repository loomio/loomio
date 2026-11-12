cmake_minimum_required(VERSION 3.21)

project(LoomioDesktop VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Network Qml Quick QuickControls2 WebEngineQuick Widgets Test)
find_package(Qt6Keychain REQUIRED)

qt_standard_project_setup(REQUIRES 6.8)

# Protocol and parsing code with no UI, shared by the app and its tests.
qt_add_library(loomio_core STATIC
    src/pkce.h src/pkce.cpp
    src/hostorigin.h src/hostorigin.cpp
    src/hostconfig.h src/hostconfig.cpp
    src/loopbackcallback.h src/loopbackcallback.cpp
)
target_include_directories(loomio_core PUBLIC src)
target_link_libraries(loomio_core PUBLIC Qt6::Core Qt6::Network)

qt_add_executable(LoomioDesktop MACOSX_BUNDLE
    src/main.cpp
    src/loopbackauthorizer.h src/loopbackauthorizer.cpp
    src/credentialstore.h src/credentialstore.cpp
    src/server.h src/server.cpp
    src/serverlist.h src/serverlist.cpp
    src/activityfeed.h src/activityfeed.cpp
    src/notifier.h src/notifier.cpp
)

qt_add_qml_module(LoomioDesktop
    URI Loomio
    VERSION 1.0
    DEPENDENCIES QtWebEngine
    QML_FILES
        qml/Main.qml
        qml/ServerRail.qml
        qml/ActivityPane.qml
        qml/ServerPage.qml
        qml/AddServerPage.qml
)

set_target_properties(LoomioDesktop PROPERTIES
    OUTPUT_NAME "Loomio"
    MACOSX_BUNDLE_GUI_IDENTIFIER org.loomio.desktop
    MACOSX_BUNDLE_BUNDLE_NAME Loomio
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
)

# Debug builds may connect to a local development server over plain HTTP.
target_compile_definitions(LoomioDesktop PRIVATE
    $<$<CONFIG:Debug>:LOOMIO_DESKTOP_ALLOW_LOCAL_HTTP>
    LOOMIO_DESKTOP_VERSION="${PROJECT_VERSION}"
)

target_link_libraries(LoomioDesktop PRIVATE
    loomio_core
    Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::WebEngineQuick Qt6::Widgets
    Qt6Keychain::Qt6Keychain
)

enable_testing()
qt_add_executable(loomio_core_tests tests/tst_core.cpp)
target_link_libraries(loomio_core_tests PRIVATE loomio_core Qt6::Test)
add_test(NAME loomio_core_tests COMMAND loomio_core_tests)
