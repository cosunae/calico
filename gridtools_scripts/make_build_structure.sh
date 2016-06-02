#!/bin/bash

function help {
  echo "No Help, you on your own"
}

while getopts  "hd:" opt; do
    case "$opt" in
    h|\?)
        help
        exit 0
        ;;
    d) BUILD_ROOT=$OPTARG
    esac
done

if [[ -z $BUILD_ROOT ]]; then
  echo "-d must be specified" 
  exit 1
fi
SOURCE_DIR=$PWD
BUILD_ROOT=$PWD/$BUILD_ROOT

function make_build {
  grid=$1
  cxx_std=$2
  target=$3
  build_type=$4

  #check disallowed options
  if [[ "$grid" == "icosahedral" && "$cxx_std" == "cxx03" ]]; then
    return
  fi
 
  mkdir -p $BUILD_ROOT/$grid/$cxx_std/$target/$build_type

  cd $BUILD_ROOT/$grid/$cxx_std/$target/$build_type
  CXX=g++-4.9
  CC=gcc-4.9

  STRUCTURED_GRIDS="ON"
  if [[ "$grid" == "icosahedral" ]]; then
    STRUCTURED_GRIDS="OFF"
  fi
  ENABLE_CXX11="ON"
  if [[ "$cxx_std" == "cxx03" ]]; then
    ENABLE_CXX11="OFF"
  fi
  USE_GPU="ON"
  if [[ "$target" == "host" ]]; then
    USE_GPU="OFF"
  fi
  CMAKE_BUILD_TYPE="$build_type"

  cmd="cmake -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_FLAGS="-D_FORCE_INLINES" -DSTRUCTURED_GRIDS=$STRUCTURED_GRIDS -DENABLE_CXX11=$ENABLE_CXX11 -DUSE_GPU=$USE_GPU -DENABLE_CXX11=$ENABLE_CXX11  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DENABLE_CXX11=$ENABLE_CXX11 $SOURCE_DIR -DGTEST_ROOT=/usr/local/gtest/4.9/"
  echo "BUILDING CONF"
  echo "GRID: $grid; CXXSTD: $cxx_std; TARGET: $target; BUILD_TYPE: $build_type" 
  echo "$cmd"
  $cmd
}

grids="structured icosahedral"
targets="host cuda"
build_types="release debug"
cxx_stds="cxx11 cxx03"

for agrid in $grids
do
  for acxx_std in $cxx_stds
  do
    for atarget in $targets
    do
      for abuild_type in $build_types
      do
        make_build $agrid $acxx_std $atarget $abuild_type
      done
    done
  done
done
