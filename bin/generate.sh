#!/bin/bash

GREEN=$'\e[32m'
UNSET=$'\e[m'

usage() {
  echo "Usage: ./generate [options]"
  echo ""
  echo "Generate icons, background images from original images."
  echo ""
  echo "Options:"
  echo "  --icon, -i       : Generate icons for dmg, nsis"
  echo "  --background, -b : Generate background.tiff for dmg"
  echo ""
  exit 1;
}

generate_icon() {
  SIZES="16 32 64 128 256 512"
  ORG_FILE="resources/icon.png"
  TMP="icon.iconset"

  cd $(dirname $0)
  cd ../build

  rm -rf ${TMP}
  mkdir ${TMP}

  for SIZE in $SIZES
  do
    FILE="icon_${SIZE}x${SIZE}.png"
    sips -Z ${SIZE} ${ORG_FILE} --out ${TMP}/${FILE}
    FILE="icon_${SIZE}x${SIZE}@2x.png"
    sips -Z $((${SIZE} * 2)) ${ORG_FILE} --out ${TMP}/${FILE}
  done

  iconutil -c icns ${TMP}
  echo "${GREEN}generated${UNSET} icon.icns"

  ARGS=""
  for SIZE in $SIZES
  do
    FILE="icon_${SIZE}x${SIZE}.png"
    ARGS="${ARGS} ${TMP}/${FILE}"
  done

  convert ${ARGS} icon.ico
  echo "${GREEN}generated${UNSET} icon.ico"

  rm -rf ${TMP}
}

generate_background() {
  SIZE="540"
  ORG_FILE="resources/background.png"
  TMP="tmp"

  cd $(dirname $0)
  cd ../build

  rm -rf ${TMP}
  mkdir ${TMP}

  sips -Z ${SIZE} ${ORG_FILE} --out ${TMP}/background.png
  sips -Z $((${SIZE} * 2)) ${ORG_FILE} --out ${TMP}/background@2x.png

  tiffutil -cathidpicheck ${TMP}/background.png ${TMP}/background@2x.png -out background.tiff
  echo "${GREEN}generated${UNSET} background.tiff"

  rm -rf ${TMP}
}

while getopts :hib-: OPT; do
  case ${OPT} in
    h)
      usage;;
    i)
      OPT_I=1;;
    b)
      OPT_B=1;;
    -)
      case ${OPTARG} in
        icon)
          OPT_I=1;;
        background)
          OPT_B=1;;
        ?)
          usage;;
      esac;;
    ?)
      usage;;
  esac
done

if [ -n "${OPT_I}" -o -z "${OPT_B}" ]; then
  generate_icon
fi

if [ -n "${OPT_B}" -o -z "${OPT_I}" ]; then
  generate_background
fi
