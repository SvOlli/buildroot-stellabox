#!/bin/bash

# name of subdir to build in
readonly build_dir="output"
# name of subdir to download buildroot tarballs to
readonly buildroot_dir="buildroot"
# points to buildroot website
readonly download_base="https://buildroot.org/downloads"
readonly tarext="tar.xz"
buildroot_version="2022.02.8" # suggested value: latest lts

# to aggregate more than one repo change this to "*/*" and copy
# setup.sh to the directory containing all the layers
readonly basedirs="*"

set -e

errmsg()
{
   echo -e "\nsomething went wrong!\ncheck error messages above\n"
   exit 1
}

trap "errmsg" ERR

cd "$(dirname "${0}")"

if [ -z "${1}" ]; then
   echo "Usage: ${0} <relative_path_to_config> (additional layer dirs)"
   echo "Available configs are:"
   ls -1 ${basedirs}/configs/*_defconfig 2>/dev/null
   echo "Additional layers are:"
   ls -1 ${basedirs}/Config.in | sed 's,/Config.in,,g' | tr '\n' ' ' | fold -s ; echo
   dl_dir="$(grep -l '^BR2_DL_DIR=' ${basedirs}/configs/*_defconfig || true)"
   if [ -n "${dl_dir}" ]; then
      sed -i -e '/^BR2_DL_DIR=/d' ${dl_dir}
   fi
   exit 0
fi

dl_dir="${PWD}/dl"
defconfig_full="${1}"
defconfig="${defconfig_full##*/}"
configname="${defconfig%_defconfig}"
shift

output_dir="${PWD}/${build_dir}/${configname}"
layer_dir="${PWD}/${defconfig_full%/configs/*}"

if [ -f "${layer_dir}/buildroot.version" ]; then
   buildroot_version="$(cat "${layer_dir}/buildroot.version")"
   buildroot_version="${buildroot_version#buildroot-}"
fi

[ -d "${buildroot_dir}" ] || mkdir "${buildroot_dir}"

if [ ! -d "${buildroot_dir}/buildroot-${buildroot_version}" ]; then
   oldpwd="${PWD}"
   cd "${buildroot_dir}"
   if [ ! -f "buildroot-${buildroot_version}.${tarext}" ]; then
      wget "${download_base}/buildroot-${buildroot_version}.${tarext}"
   fi
   tar xf "buildroot-${buildroot_version}.${tarext}"
   cd "${oldpwd}"
fi

layer_dirs="${layer_dir}"
for extra_layer; do
   extra_layer="$(readlink -f "${extra_layer}")"
   if [ ! -f "${extra_layer}/Config.in" -o \
        ! -f "${extra_layer}/external.mk" -o \
        ! -f "${extra_layer}/external.desc" ]; then
      echo "can't add layer ${extra_layer}: core file(s) missing"
      exit 1
   else
      layer_dirs="${layer_dirs}:${extra_layer}"
   fi
done

sed -i -e '/^BR2_DL_DIR=/d' "${defconfig_full}"
make O="${output_dir}" BR2_EXTERNAL="${layer_dir}" -C "${buildroot_dir}/buildroot-${buildroot_version}" "${defconfig}"
# is there a better way than patching ".config"?
sed -i "${output_dir}/.config" \
    -e "s|^BR2_DL_DIR=.*|BR2_DL_DIR=\"${dl_dir}\"|"

echo "all set, go to \"${output_dir#${PWD}/}\" and run \"make all\""
if [ -x "/usr/bin/dpkg" ]; then
   dpkg --get-selections | grep -q ^libelf-dev || echo "you should install \"libelf-dev\""
fi
