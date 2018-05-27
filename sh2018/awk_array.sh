#!/bin/bash

# awk 中数组下标是从1开始的，注意与c语言的区别

# for .. in .. 里面是无序的
awk 'BEGIN{text="this is a test";split(text,tA," ");for(k in tA) {printf("%d --> %s\n", k, tA[k]);}}'

echo '--------------------------'

# 通过下标来访问数组是有序的
awk 'BEGIN{text="this is a test";tlen=split(text,tA," ");for(k=1;k<=tlen;k++) {printf("%d --> %s\n", k, tA[k]);}}'


# 一些详细的高级用法可以参考
# https://blog.csdn.net/ithomer/article/details/8478716
