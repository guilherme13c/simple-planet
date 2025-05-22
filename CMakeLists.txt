cmake_minimum_required(VERSION 3.14)
project(simple-planet)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

include(FetchContent)

set(GLAD_ZIP ${CMAKE_SOURCE_DIR}/external/glad.zip)
set(GLAD_UNZIP_DIR ${CMAKE_SOURCE_DIR}/dependencies/glad)
set(FETCHCONTENT_BASE_DIR ${CMAKE_SOURCE_DIR}/dependencies)

find_package(Python3 COMPONENTS Interpreter REQUIRED)

# GLFW
FetchContent_Declare(
  glfw
  GIT_REPOSITORY https://github.com/glfw/glfw.git
  GIT_TAG        3.4
)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_WAYLAND ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(glfw)

# GLM
FetchContent_Declare(
  glm
  GIT_REPOSITORY https://github.com/g-truc/glm.git
  GIT_TAG        1.0.1
)
FetchContent_MakeAvailable(glm)

# Assimp
FetchContent_Declare(
  assimp
  GIT_REPOSITORY https://github.com/assimp/assimp.git
  GIT_TAG        v5.2.5
)
set(ASSIMP_NO_EXPORT ON CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_ASSIMP_TOOLS OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_OBJ_IMPORTER ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(assimp)

# GLAD
if(NOT EXISTS ${GLAD_UNZIP_DIR}/include/glad/glad.h)
  file(MAKE_DIRECTORY ${GLAD_UNZIP_DIR})
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar xzf ${GLAD_ZIP}
    WORKING_DIRECTORY ${GLAD_UNZIP_DIR}
    RESULT_VARIABLE UNZIP_RESULT
  )
  if(NOT UNZIP_RESULT EQUAL 0)
    message(FATAL_ERROR "Failed to unzip glad.zip")
  endif()
endif()
add_library(glad STATIC ${GLAD_UNZIP_DIR}/src/glad.c)
target_include_directories(glad PUBLIC ${GLAD_UNZIP_DIR}/include)

add_executable(simple-planet src/main.cc)

set_target_properties(simple-planet PROPERTIES UNITY_BUILD ON)

target_link_libraries(simple-planet PRIVATE glad glfw glm::glm assimp)

# Link OpenGL
find_package(OpenGL REQUIRED)
target_link_libraries(simple-planet PRIVATE OpenGL::GL)
