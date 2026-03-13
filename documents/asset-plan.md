# 原型素材清单

目标：明确当前开发阶段实际需要的素材，并将其映射到当前使用的第三方素材包，保证开发阶段不因正式美术缺失而停滞。

## 素材来源

- 当前统一使用：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/`
- 当前阶段不制作正式美术
- 如果素材包内风格与设定不完全一致，以“可玩原型优先”

## 视觉选择结论

### 主角

- 采用：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/`
- 选择原因：
  - 绿色斗篷形象最接近“村落出身、野外探索”的视觉方向
  - 轮廓清晰，四方向动作完整，适合当前原型直接接入

### 敌人

- `雨孢残骸`
  - 采用：`asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/4/`
  - 原因：轮廓最硬，适合作为标准近战怪

- `雨虫群`
  - 采用：`asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/2/`
  - 原因：体型小，适合作为骚扰/爆裂单位

- `湿壳拾荒鼠`
  - 采用：`asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/1/`
  - 原因：最适合做小体型高速扑咬单位

- 暂不使用：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/3/`
  - 原因：与当前原型敌人分工重复，优先级低

### 地图与场景

- 主 tileset：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/5Tiled_files/Tileset.png`

- 物件：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/5Tiled_files/Objects.png`
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/2 Dungeon Tileset/2 Objects/`

- 视觉处理原则：
  - 先统一解释为“寒冷石构避居地 + 废弃外围”
  - 当前阶段不追求“永宁村”专属正式风格

### UI

- 状态条：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/4 GUI/4 Bars/BarsMap.png`

- 按钮：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/4 GUI/2 Buttons/ButtonsMap.png`

- 面板底图：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/4 GUI/1 Interface/`

- 图标：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/4 GUI/3 Icons/`
  - 当前阶段只挑交互提示和基础菜单图标

## 当前实际需要的素材

### 角色

- 主角四方向待机
- 主角四方向移动
- 主角四方向攻击
- 主角四方向受击
- 主角四方向死亡
- 主角阴影

### 敌人

- `雨孢残骸` 四方向待机/移动/攻击/受击/死亡
- `雨虫群` 四方向待机/移动/攻击/受击/死亡
- `湿壳拾荒鼠` 四方向待机/移动/攻击/受击/死亡
- 敌人公共阴影
- 敌人公共血花/受击特效

### 地图

- 地面 tile
- 墙体 tile
- 通道 tile
- 转角 tile
- 门口或入口 tile
- 栅栏/路障替代物件
- 避难所核心交互物件
- 简单环境装饰物件

### UI

- 生命条
- 体力条
- 主菜单按钮
- 基础面板底图
- 交互提示图标

### 剧情占位

- 山海回响占位图
- 影隐现身占位图

## 推荐文件映射

### 主角

- 角色预览：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/1.png`

- 动画来源：
  - `D_Idle.png`
  - `D_Walk.png`
  - `D_Attack.png`
  - `D_Hurt.png`
  - `D_Death.png`
  - `S_Idle.png`
  - `S_Walk.png`
  - `S_Attack.png`
  - `S_Hurt.png`
  - `S_Death.png`
  - `U_Idle.png`
  - `U_Walk.png`
  - `U_Attack.png`
  - `U_Hurt.png`
  - `U_Death.png`

- 公共附加：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/Other/Shadow.png`

### 敌人

- `雨孢残骸`
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/4/4.png`

- `雨虫群`
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/2/2.png`

- `湿壳拾荒鼠`
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/1/1.png`

- 公共附加：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/Other/Shadow.png`
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/Other/D_Blood.png`
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/Other/S_Blood.png`
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/Other/U_Blood.png`

### 地图与 UI

- Tileset：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/5Tiled_files/Tileset.png`

- Objects：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/5Tiled_files/Objects.png`

- 状态条：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/4 GUI/4 Bars/BarsMap.png`

- 按钮：
  - `asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/4 GUI/2 Buttons/ButtonsMap.png`

## 剧情占位策略

- 山海回响
  - 当前阶段不做正式立绘
  - 先用主角素材做半透明重着色剪影，或使用静态轮廓占位

- 影隐
  - 当前阶段不做正式狼形素材
  - 先用黑色或白色 silhouette 占位，只承担远景现身功能

## 当前不需要准备的素材

- 正式角色立绘
- 正式村庄建筑风格图块
- 法术特效
- 复杂 Boss 动画
- 商店、背包、装备栏完整 UI
- 长兵与远程武器素材

## 使用原则

- 优先直接引用第三方素材包中的现成文件
- 只为当前真正要落地的内容挑素材
- 后续正式美术替换时，以功能映射替换，不返工系统结构
