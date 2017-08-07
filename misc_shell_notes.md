### 进制转化

Shell脚本中数值都是默认按照十进制处理的，除非这个数值做了特殊标记，如：以 0 开头就是 8 进制数，以0x 开头就是16 进制数；另外 **BASE#NUMBER** 这种形式可以表示其它进制，BASE值：2-64。

```shell
((num=0xff)); echo $num
255
((num=0123)); echo $num
83
((num=8#123)); echo $num
83
((num=64#123)); echo $num
4227
```



