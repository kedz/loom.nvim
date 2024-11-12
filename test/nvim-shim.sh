#!/bin/sh

export XDG_CONFIG_HOME='test/xdg/config/'
export XDG_STATE_HOME='test/xdg/local/state/'
export XDG_DATA_HOME='test/xdg/local/share/'

ln -s $(pwd) ${XDG_DATA_HOME}/nvim/site/pack/testing/start/loom.nvim
nvim --cmd 'set loadplugins' -u "${XDG_CONFIG_HOME}/nvim/init.lua" -l $@
exit_code=$?
rm ${XDG_DATA_HOME}/nvim/site/pack/testing/start/loom.nvim

exit $exit_code
