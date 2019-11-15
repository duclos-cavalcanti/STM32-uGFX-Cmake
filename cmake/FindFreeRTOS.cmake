IF(STM32_FAMILY STREQUAL "F0")
    SET(PORT_GCC_DIR_SUFFIX "CM0")
ELSEIF(STM32_FAMILY STREQUAL "F1")
    SET(PORT_GCC_DIR_SUFFIX "CM3")
ELSEIF(STM32_FAMILY STREQUAL "F2")
    SET(PORT_GCC_DIR_SUFFIX "CM3")
ELSEIF(STM32_FAMILY STREQUAL "F3")
    SET(PORT_GCC_DIR_SUFFIX "CM4F")
ELSEIF(STM32_FAMILY STREQUAL "F4")
    SET(PORT_GCC_DIR_SUFFIX "CM4F")
ELSEIF(STM32_FAMILY STREQUAL "F7")
    SET(PORT_GCC_DIR_SUFFIX "CM7")
ELSEIF(STM32_FAMILY STREQUAL "L0")
    SET(PORT_GCC_DIR_SUFFIX "CM0")
ELSEIF(STM32_FAMILY STREQUAL "L1")
    SET(PORT_GCC_DIR_SUFFIX "CM4F")
ENDIF()

SET(FREERTOS_CMSIS_HEADERS
    cmsis_gcc.h
    )

SET(FREERTOS_SRC_FILES
    croutine.c
    event_groups.c
    list.c
    queue.c
    tasks.c
    timers.c
    )

SET(FREERTOS_HEADERS
    croutine.h
    deprecated_definitions.h
    event_groups.h
    FreeRTOS.h
    list.h
    mpu_prototypes.h
    mpu_wrappers.h
    portable.h
    projdefs.h
    queue.h
    semphr.h
    StackMacros.h
    task.h
    timers.h
    )

SET(CMSIS_OS_SRC_FILE cmsis_os.c)
SET(CMSIS_OS_INC_FILE cmsis_os.h)

SET(PORT_ARM_SRC_FILE port.c)
SET(PORTMACRO_ARM_HEADER portmacro.h)

IF(NOT FREERTOS_HEAP_IMPL)
    MESSAGE(FATAL_ERROR "FREERTOS_HEAP_IMPL not defined. Define it to include proper heap implementation file.")
ELSE()
    SET(HEAP_IMP_FILE heap_${FREERTOS_HEAP_IMPL}.c)
ENDIF()

FIND_PATH(FREERTOS_COMMON_INC_DIR ${FREERTOS_HEADERS}
    PATH_SUFFIXES include
    HINTS ${STM32Cube_DIR}/Middlewares/Third_Party/FreeRTOS/Source
    CMAKE_FIND_ROOT_PATH_BOTH
    )

FIND_PATH(CMSIS_OS_INC_DIR ${CMSIS_OS_INC_FILE}
    PATH_SUFFIXES CMSIS_RTOS
    HINTS ${STM32Cube_DIR}/Middlewares/Third_Party/FreeRTOS/Source
    CMAKE_FIND_ROOT_PATH_BOTH
    )

FOREACH(HEADER ${FREERTOS_CMSIS_HEADERS})
    FIND_PATH(INC_DIR
        NAME ${HEADER}
        HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Include
        CMAKE_FIND_ROOT_PATH_BOTH
        )
    LIST(APPEND CMSIS_OS_INC_DIR ${INC_DIR})
ENDFOREACH()

MESSAGE("AA: ${CMSIS_OS_INC_DIR}")

FIND_PATH(PORTMACRO_INC_DIR ${PORTMACRO_ARM_HEADER}
    PATH_SUFFIXES ARM_${PORT_GCC_DIR_SUFFIX}
    HINTS ${STM32Cube_DIR}/Middlewares/Third_Party/FreeRTOS/Source/portable/GCC
    CMAKE_FIND_ROOT_PATH_BOTH
    )

FOREACH(SRC ${FREERTOS_SRC_FILES})
    STRING(MAKE_C_IDENTIFIER "${SRC}" SRC_CLEAN)
    SET(FREERTOS_${SRC_CLEAN}_FILE FREERTOS_SRC_FILE-NOTFOUND)
    FIND_FILE(FREERTOS_${SRC_CLEAN}_FILE ${SRC}
        HINTS ${STM32Cube_DIR}/Middlewares/Third_Party/FreeRTOS/Source
        CMAKE_FIND_ROOT_PATH_BOTH
        )
    LIST(APPEND FREERTOS_SOURCES ${FREERTOS_${SRC_CLEAN}_FILE})
ENDFOREACH()

FIND_FILE(CMSIS_OS_SOURCE ${CMSIS_OS_SRC_FILE}
    PATH_SUFFIXES CMSIS_RTOS
    HINTS ${STM32Cube_DIR}/Middlewares/Third_Party/FreeRTOS/Source
    CMAKE_FIND_ROOT_PATH_BOTH
    )

FIND_FILE(PORT_ARM_SOURCE ${PORT_ARM_SRC_FILE}
    PATH_SUFFIXES ARM_${PORT_GCC_DIR_SUFFIX}
    HINTS ${STM32Cube_DIR}/Middlewares/Third_Party/FreeRTOS/Source/portable/GCC
    CMAKE_FIND_ROOT_PATH_BOTH
    )

FIND_FILE(HEAP_IMP_SOURCE ${HEAP_IMP_FILE}
    PATH_SUFFIXES MemMang
    HINTS ${STM32Cube_DIR}/Middlewares/Third_Party/FreeRTOS/Source/portable
    CMAKE_FIND_ROOT_PATH_BOTH
    )

SET(FreeRTOS_INCLUDE_DIRS
    ${FREERTOS_COMMON_INC_DIR}
    ${CMSIS_OS_INC_DIR}
    ${PORTMACRO_INC_DIR}
    )

SET(FreeRTOS_SOURCES
    ${FREERTOS_SOURCES}
    ${CMSIS_OS_SOURCE}
    ${PORT_ARM_SOURCE}
    ${HEAP_IMP_SOURCE}
    )

INCLUDE(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(FreeRTOS DEFAULT_MSG FreeRTOS_INCLUDE_DIRS FreeRTOS_SOURCES)
