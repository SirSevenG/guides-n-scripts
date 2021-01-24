set -ex

# ndk script, modified to be used with GitLab docker containers

NDK_URL=https://dl.google.com/android/repository/android-ndk-r21b-linux-x86_64.zip

main() {
    local arch=$1 \
          api=$2

    local dependencies=(
        unzip
        python
	curl
    )

    apt-get update
    local purge_list=()
    for dep in ${dependencies[@]}; do
        if ! dpkg -L $dep; then
            apt-get install --no-install-recommends -y $dep
            purge_list+=( $dep )
        fi
    done

    td=$(mktemp -d)

    pushd $td
    curl -O $NDK_URL
    unzip -q android-ndk-*.zip
    pushd android-ndk-*/
    ./build/tools/make_standalone_toolchain.py \
      --install-dir /android-ndk \
      --arch $arch \
      --api $api

    # clean up
    apt-get purge --auto-remove -y ${purge_list[@]}

    popd
    popd

    rm -rf $td
}

main "${@}"
