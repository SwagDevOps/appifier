#!/usr/bin/env sh
# -*- coding: utf-8 -*-

# @see https://github.com/AppImage/pkg2appimage/blob/678e5e14122f14a12c54847213585ea803e1f0e1/pkg2appimage-with-docker#L92

docker run -it \
    --name $containerid \
    --cap-add SYS_ADMIN \
    --device /dev/fuse \
    --security-opt apparmor:unconfined \
    --user $(id -u):$(id -g) \
    -v "$(readlink -f out):/workspace/out" \
    -v "$(readlink -f pkg2appimage):/workspace/pkg2appimage:ro" \
    -v "$(readlink -f $RECIPE):/workspace/$RECIPE:ro" \
    $ARGS \
    $imageid \
    ./pkg2appimage $RECIPE || cleanup error
