#!/bin/bash

# fix due to Wine; see https://github.com/Mozilla-Ocho/llamafile/issues/373
if [[ "${CI}" != "" && "${OSTYPE}" == "linux-gnu" ]]; then
    sudo wget -O /usr/bin/ape https://cosmo.zip/pub/cosmos/bin/ape-$(uname -m).elf
    sudo chmod +x /usr/bin/ape
    sudo sh -c "echo ':APE:M::MZqFpD::/usr/bin/ape:' >/proc/sys/fs/binfmt_misc/register"
    sudo sh -c "echo ':APE-jart:M::jartsr::/usr/bin/ape:' >/proc/sys/fs/binfmt_misc/register"
fi

ZIP_NAME=${ZIP_NAME:-install_dir/bin}
LLAMAFILE_VER="0.9.1"
OLD_PWD=$(pwd)
cd "${ZIP_NAME}"
if [[ ! -f ./llamafiler-${LLAMAFILE_VER}.exe ]]; then
  curl -L -o llamafiler-${LLAMAFILE_VER}.exe https://github.com/Mozilla-Ocho/llamafile/releases/download/${LLAMAFILE_VER}/llamafiler-${LLAMAFILE_VER}
fi
if [[ ! -f ./all-MiniLM-L6-v2-Q5_K_M.gguf ]]; then
  curl -L -o all-MiniLM-L6-v2-Q5_K_M.gguf https://huggingface.co/second-state/All-MiniLM-L6-v2-Embedding-GGUF/resolve/main/all-MiniLM-L6-v2-Q5_K_M.gguf?download=true
fi
# if [[ ! -f ./Mistral-7B-Instruct-v0.3.Q4_K_M.gguf ]]; then
#   curl -L -o Mistral-7B-Instruct-v0.3.Q4_K_M.gguf https://huggingface.co/MaziyarPanahi/Mistral-7B-Instruct-v0.3-GGUF/resolve/main/Mistral-7B-Instruct-v0.3.Q4_K_M.gguf?download=true
# fi

chmod +x ./llamafiler-${LLAMAFILE_VER}.exe

# start server in background
./llamafiler-${LLAMAFILE_VER}.exe -m all-MiniLM-L6-v2-Q5_K_M.gguf &

# wait for server start
sleep 2

cd "${OLD_PWD}"
