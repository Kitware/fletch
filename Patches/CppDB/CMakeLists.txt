cmake_minimum_required(VERSION 3.5)
project(cppdb)

set(CPPDB_MAJOR 0)
set(CPPDB_MINOR 3)
set(CPPDB_PATCH 0)

set(CPPDB_VERSION ${CPPDB_MAJOR}.${CPPDB_MINOR}.${CPPDB_PATCH})
set(CPPDB_SOVERSION ${CPPDB_MAJOR})

add_definitions(
		-DCPPDB_MAJOR=${CPPDB_MAJOR}
		-DCPPDB_MINOR=${CPPDB_MINOR}
		-DCPPDB_PATCH=${CPPDB_PATCH}
		-DCPPDB_VERSION="${CPPDB_MAJOR}.${CPPDB_MINOR}.${CPPDB_PATCH}"
	)

option(DISABLE_SQLITE	"Link sqlite3 backend into the libcppdb" OFF)
option(DISABLE_PQ 	"Link postgresql backend into the libcppdb" OFF)
option(DISABLE_MYSQL	"Link mysql backend into the libcppdb" ON)
option(DISABLE_ODBC	"Link odbc backend into the libcppdb" ON)


option(SQLITE_BACKEND_INTERNAL	"Link sqlite3 backend into the libcppdb" OFF)
option(PQ_BACKEND_INTERNAL 	"Link postgresql backend into the libcppdb" OFF)
option(MYSQL_BACKEND_INTERNAL	"Link mysql backend into the libcppdb" OFF)
option(ODBC_BACKEND_INTERNAL	"Link odbc backend into the libcppdb" ON)

# add the CMake directory for CMake modules
set(CMAKE_MODULE_PATH ${cppdb_SOURCE_DIR} ${CMAKE_MODULE_PATH})

# General settings

include_directories(.)

add_definitions(-DCPPDB_LIBRARY_PREFIX="${CMAKE_SHARED_LIBRARY_PREFIX}")
add_definitions(-DCPPDB_LIBRARY_SUFFIX="${CMAKE_SHARED_LIBRARY_SUFFIX}")
add_definitions(-DCPPDB_SOVERSION="${CPPDB_SOVERSION}")

# Basic common configuration

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING
        "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
	      FORCE)
endif(NOT CMAKE_BUILD_TYPE)


include(CheckLibraryExists)
include(CheckCXXSourceCompiles)

if(NOT WIN32)
	find_library(DL_LIB dl)
	find_library(PTHREAD_LIB pthread NAMES thr kse)
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
	set(CXX_FLAGS "-Wall -Wextra")
	if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
		set(CXX_FLAGS "${CXX_FLAGS} -pthreads")
	endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
	set(CXX_FLAGS "-Wall")
elseif(MSVC)
	set(CXX_FLAGS "/EHsc /W3")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "SunPro")
	if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
		set(CXX_FLAGS "${CXX_FLAGS} -mt")
	endif()
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_FLAGS}")


check_cxx_source_compiles(
	"int main() { volatile int v=0; return __sync_bool_compare_and_swap(&v,0,1); }"
	CPPDB_HAS_GCC_SYNC)
if(CPPDB_HAS_GCC_SYNC)
	add_definitions(-DCPPDB_HAS_GCC_SYNC)
endif()

check_cxx_source_compiles(
	"#include <bits/atomicity.h> 
	using __gnu_cxx::__exchange_and_add;
	int main(){ volatile int x=0; return __exchange_and_add(&x,1);}"
	CPPDB_HAVE_GCC_BITS_EXCHANGE_AND_ADD)
if(CPPDB_HAVE_GCC_BITS_EXCHANGE_AND_ADD)
	add_definitions(-DCPPDB_HAVE_GCC_BITS_EXCHANGE_AND_ADD)
endif()

check_cxx_source_compiles(
	"#include <ext/atomicity.h> 
	using __gnu_cxx::__exchange_and_add;
	int main(){ volatile int x=0; return __exchange_and_add(&x,1);}"
	CPPDB_HAVE_GCC_EXT_EXCHANGE_AND_ADD)
if(CPPDB_HAVE_GCC_EXT_EXCHANGE_AND_ADD)
	add_definitions(-DCPPDB_HAVE_GCC_EXT_EXCHANGE_AND_ADD)
endif()

check_cxx_source_compiles(
	"#include <sys/types.h>
	#include <machine/atomic.h>
	int main() { volatile unsigned v=0; return atomic_cmpset_int(&v,1,0); }"
	CPPDB_HAVE_FREEBSD_ATOMIC)

if(CPPDB_HAVE_FREEBSD_ATOMIC)
	add_definitions(-DCPPDB_HAVE_FREEBSD_ATOMIC)
endif()

check_cxx_source_compiles(
	"#include <atomic.h>
	int main() { volatile unsigned v=0; return atomic_add_int_nv(&v,1); }"
	CPPDB_HAVE_SOLARIS_ATOMIC)
if(CPPDB_HAVE_SOLARIS_ATOMIC)
	add_definitions(-DCPPDB_HAVE_SOLARIS_ATOMIC)
endif()


check_cxx_source_compiles(
	"#include <libkern/OSAtomic.h>
	int main() { volatile int v=0; return OSAtomicAdd32(1,&v); }"
	CPPDB_HAVE_MAC_OS_X_ATOMIC)

if(CPPDB_HAVE_MAC_OS_X_ATOMIC)
	add_definitions(-DCPPDB_HAVE_MAC_OS_X_ATOMIC)
endif()

# Backend configuration

set(INTERNAL_SOURCES)
set(INTERNAL_LIBRARIES)
set(BACKEND_LIBRARIES)

if(NOT DISABLE_ODBC)
	find_library(ODBC_LIB odbc NAMES odbc32)
	find_path(ODBC_PATH sqlext.h)
	if(ODBC_LIB AND ODBC_PATH)
		include_directories(${ODBC_PATH})
		if(ODBC_BACKEND_INTERNAL)
			set(INTERNAL_SOURCES ${INTERNAL_SOURCES} drivers/odbc_backend.cpp)
			set(INTERNAL_LIBRARIES ${INTERNAL_LIBRARIES} ${ODBC_LIB})
			add_definitions(-DCPPDB_WITH_ODBC)
		else()
			add_library(cppdb_odbc SHARED drivers/odbc_backend.cpp)
			target_link_libraries(cppdb_odbc ${ODBC_LIB})
			add_library(cppdb_odbc-static STATIC drivers/odbc_backend.cpp)
			set(BACKEND_LIBRARIES ${BACKEND_LIBRARIES} cppdb_odbc)
		endif()
	else()
		message("-- odbc library was not found, disabling odbc backend")
	endif()
endif()

if(NOT DISABLE_SQLITE)
	find_package(SQLite 3.3.6)
	if(SQLite_FOUND)
		include_directories(${SQLite_INCLUDE_DIR})
		if(SQLITE_BACKEND_INTERNAL)
			add_definitions(-DCPPDB_WITH_SQLITE3)
			set(INTERNAL_SOURCES ${INTERNAL_SOURCES} drivers/sqlite3_backend.cpp)
			set(INTERNAL_LIBRARIES ${INTERNAL_LIBRARIES} ${SQLite_LIBRARY})
		else()
			add_library(cppdb_sqlite3 SHARED drivers/sqlite3_backend.cpp)
			target_link_libraries(cppdb_sqlite3 ${SQLite_LIBRARY})
			add_library(cppdb_sqlite3-static STATIC drivers/sqlite3_backend.cpp)
			set(BACKEND_LIBRARIES ${BACKEND_LIBRARIES} cppdb_sqlite3)
		endif()
	else()
		message("-- sqlite3 library was not found, disabling sqlite3 backend")
	endif()
endif()

if(NOT DISABLE_PQ)
	find_package(PostgreSQL)
	message("PostgreSQL includes:  ${PostgreSQL_INCLUDE_DIRS}")
	message("PostgreSQL library:   ${PostgreSQL_LIBRARY}")
	message("PostgreSQL libraries: ${PostgreSQL_LIBRARIES}")
	if(PostgreSQL_FOUND)
		include_directories(${PostgreSQL_INCLUDE_DIRS})
		if(PQ_BACKEND_INTERNAL)
			set(INTERNAL_SOURCES ${INTERNAL_SOURCES} drivers/postgres_backend.cpp)
			set(INTERNAL_LIBRARIES ${INTERNAL_LIBRARIES} ${PostgreSQL_LIBRARY})
			add_definitions(-DCPPDB_WITH_PQ)
		else()
			add_library(cppdb_postgresql SHARED drivers/postgres_backend.cpp)
			add_library(cppdb_postgresql-static STATIC drivers/postgres_backend.cpp)
			target_link_libraries(cppdb_postgresql ${PostgreSQL_LIBRARY})
			set(BACKEND_LIBRARIES ${BACKEND_LIBRARIES} cppdb_postgresql)
		endif()
	else()
		message("-- libpq not found, disableing postgresql backend")
	endif()
endif()

if(NOT DISABLE_MYSQL)
	find_library(MYSQL_LIB mysqlclient)
	find_path(MYSQL_PATH mysql.h PATH_SUFFIXES mysql)
	if(MYSQL_LIB AND MYSQL_PATH)
		include_directories(${MYSQL_PATH})
		if(MYSQL_BACKEND_INTERNAL)
			set(INTERNAL_SOURCES ${INTERNAL_SOURCES} drivers/mysql_backend.cpp)
			set(INTERNAL_LIBRARIES ${INTERNAL_LIBRARIES} ${MYSQL_LIB})
			add_definitions(-DCPPDB_WITH_MYSQL)
		else()
			add_library(cppdb_mysql SHARED drivers/mysql_backend.cpp)
			add_library(cppdb_mysql-static STATIC drivers/mysql_backend.cpp)
			target_link_libraries(cppdb_mysql ${MYSQL_LIB})
			set(BACKEND_LIBRARIES ${BACKEND_LIBRARIES} cppdb_mysql)
		endif()
	else()
		message("-- mysqlclient not found, disableing mysql backend")
	endif()
endif()


# Main library configuration

set(CPPDB_SRC
	src/utils.cpp
	src/mutex.cpp
	src/driver_manager.cpp
	src/conn_manager.cpp
	src/shared_object.cpp
	src/pool.cpp
	src/backend.cpp
	src/frontend.cpp
	src/atomic_counter.cpp
	${INTERNAL_SOURCES}
	)

add_library(cppdb SHARED ${CPPDB_SRC})
add_library(cppdb-static STATIC ${CPPDB_SRC})
set_target_properties(cppdb PROPERTIES COMPILE_DEFINITIONS CPPDB_EXPORTS)

if(NOT WIN32)
	if(DL_LIB)
		target_link_libraries(cppdb ${DL_LIB})
	endif()
	target_link_libraries(cppdb ${PTHREAD_LIB})
endif()

# Link and backends configuration

set(INST_LIBS)



foreach(LIB ${BACKEND_LIBRARIES} cppdb)
	
	set(INST_LIBS ${INST_LIBS} ${LIB} ${LIB}-static)

	if(WIN32)
		set_target_properties(${LIB} PROPERTIES VERSION ${CPPDB_SOVERSION} SOVERSION ${CPPDB_SOVERSION})
	else()
		set_target_properties(${LIB} PROPERTIES VERSION ${CPPDB_VERSION} SOVERSION ${CPPDB_SOVERSION})
	endif()

    
	set_target_properties(${LIB} PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(${LIB} PROPERTIES OUTPUT_NAME "${LIB}")
	set_target_properties(${LIB}-static PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(${LIB}-static PROPERTIES OUTPUT_NAME "${LIB}")
	set_target_properties(${LIB}-static PROPERTIES PREFIX "lib") # Make sure import and normal library do not collide

 endforeach()

foreach(LIB ${BACKEND_LIBRARIES})
	set_target_properties(${LIB} PROPERTIES COMPILE_DEFINITIONS CPPDB_DRIVER_EXPORTS)
	target_link_libraries(${LIB} cppdb)
endforeach()

foreach(LIB ${INTERNAL_LIBRARIES})
	target_link_libraries(cppdb ${LIB})
endforeach()

# tests

add_executable(test_perf test/test_perf.cpp)
add_executable(test_basic test/test_basic.cpp)
add_executable(test_backend test/test_backend.cpp)
add_executable(test_caching test/test_caching.cpp)
add_executable(example examples/example1.cpp)

set_target_properties(	test_perf test_backend test_basic test_caching example 
			PROPERTIES 
				COMPILE_DEFINITIONS CPPDB_EXPORTS)

target_link_libraries(test_perf cppdb)
target_link_libraries(test_basic cppdb)
target_link_libraries(test_backend cppdb)
target_link_libraries(test_caching cppdb)
target_link_libraries(example cppdb)

install(TARGETS ${INST_LIBS} 
	RUNTIME DESTINATION bin
	LIBRARY DESTINATION lib
	ARCHIVE DESTINATION lib
	PUBLIC_HEADER DESTINATION include/cppdb)

install(DIRECTORY cppdb DESTINATION include
        PATTERN ".svn" EXCLUDE)



