#!/bin/bash
for x in {0..8}; do 
    for i in {30..37}; do 
        for a in {40..47}; do 
            printf '\e[%d;%d;%dm \\e[%d;%d;%dm \e[0m ' $x $a $i $x $a $i
        done
        echo
    done
done
echo ""
