#!/bin/bash
for i in {0..255}; do printf "\e[48;5;%sm %3s \e[0m" "$i" "$i"; (( (i+1) % 16 == 0 )) && echo; done

