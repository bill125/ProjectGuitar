# 基本
1. **蓝牙！！**

   1. 板子如何读取和发送蓝牙信息 //A
   2. 手机（iTouch）如何读取和发送蓝牙信息 //B
   3. usb调试蓝牙 //A
2. 手机播放、停止播放 //B
3. 键盘输入 //A

# 进阶

1. 实现 loop //A
2. 多种音源切换 //B
3. 迷你节奏大师 //A,B
   1. Vga
      1. 方块
      2. hit effectg
   2. 逻辑模块



# 旋律类

数组，每一项包含：音高、乐器编号、发声时间

# 传输协议

手机->Fpga：6个0-88的整数，代表6条弦音高。总共12位十六进制。

FGPA->手机：isOn(1 or 0 表示按下还是释放，暂且全部设为1) key(音高0-88) vel(音量0-127) prog(乐器类别0-127, 大于127则认为乐器不变) 8位十六进制

# 音量



# 弹奏

分工：L

输入：

1. 6条弦、

2. 键盘

输出：

1. 音高

# Loop

分工：L

用状态机设计：两种状态：未录制、录制

输入：

1. 开始\结束
2. 录音编号（事先在SRAM中分配3段内存用于存储）
3. 音高
4. 乐器编号

输出：

1. 旋律


将整体旋律写入sram

# 游戏

分工：未定

用状态机设计：两种状态：未开始、开始

输入：

1. 开始\结束、
2. 音高

输出：

1. 正确音高
2. 用户音高

用vga处理输出























