:: 注释：定义 var 变量，这个是容器的名字
set var=mppocr
:: shell_op是linux容器中的脚本，被 docker exec 带参数执行，相当于Linux自启动脚本
set shell_op=/home/shell_op/op.sh
title ^START PPOCR
echo statring container.....
docker start %var%
echo This is where the script executes inside the container: %shell_op%
docker exec -it %var% /bin/bash %shell_op%
echo end......
PAUSE