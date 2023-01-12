# Logic-Design-Laboratory-final-project
Logic Design Laboratory final project

# 基本不需要動的東西 : other.v
music_gen

note_gen

speaker_control

clock_divider

KeyboardDecoder

OnePulse

vga_controller

# 控制音樂播放 : music.v

player_control : 計算ibeat(播放第幾個音)

music_example_01 : 背景音樂

sound_effect(optional) : 音效

根據stage不同播放對應BGM，並在碰撞發生時產生音效

# 控制與球相關的移動、碰撞結果 : ball.v

### ball_control : 控制球的移動，根據傳入資料(磚塊位置、板子位置、...)，輸出球下一刻位置

input : bricks、ball_x、ball_y、ball_vx、ball_vy

output : next_bricks、next_ball_x、next_ball_y、next_ball_vx、next_ball_vy、skillbar_drop

計算球的新位置與新速度；判定球是否碰撞，若碰撞到磚塊，破壞或掉落物品(球的碰撞箱視為正方形)

### 實作細項

紀錄球的座標(x, y)以及速度(vx, vy)，每個clockedge位置變為(x+vx, y+vy)。

以(x+vx, y+vy)判斷碰撞是否發生，以及碰撞的方向(上下左右)，並透過目前速度，來決定碰撞後的速度為何。

磚塊被碰到後的狀態在這裡更新

bricks 的特殊紀錄方式 : 每三個bit紀錄一個磚塊位置，將整塊畫面以15*30大小切割。

(可能作法)若會碰撞技能磚塊並掉落技能條，將對應skillbar_drop座標為1，之後由main生成技能條。

(可能作法)球碰撞後的速度可以使用random來偏斜一點角度，增加遊戲隨機性，並避免球永遠直上直下的情況

# 以鍵盤控制板子移動 : control.v

board_move : 回傳板子下一刻位置

根據鍵盤左右鍵操控板子，紀錄座標(x, y)以及速度(vx, vy)，每個clockedge位置變為(x+vx, y+vy)。

(可能作法)若移動的板子碰到球，根據板子速度偏斜球彈回角度

# 讀取圖片 : image.v

### main_addr_gen : 真正返回pixel_addr的module

根據磚塊、球、板子、技能條位置與h_cnt、v_cnt，判斷目前要印出哪種物件，並給與對應module計算後的input，並輸出其ouput address

### 各物件address module

mem_addr_gen_background 

mem_addr_gen_ball 

mem_addr_gen_board 

mem_addr_gen_skillbar

mem_addr_gen_brick_a 

mem_addr_gen_brick_b 

...

# 控制各個module的輸入輸出，以及主要的clock cycle(刷新率) : main.v

main

### 目前內容

初始化各參數、呼叫各module

# 版本

版本一 : 
能顯示球、背景、磚塊、板子
板子能動、球能動、碰到物體會反彈、磚塊碰到一下後消失


版本二 : 
增加背景音樂、音效
增加遊戲UI
增加遊戲首頁、結束畫面

版本三 : 
增加特殊磚塊、關卡設計、技能(板子變化、球變化、球移動軌跡變化...)、以及其他加分內容
