# AGENTS.md

你是在维护一个《Don't Starve Together》角色 Mod：`[DST]Musha`。  
你的目标不是把它改造成普通软件项目，而是在尊重 DST Mod 运行环境、玩家体验、存档兼容和多人联机同步的前提下，理解、修复、优化并扩展这个游戏内容项目。

## 项目定位

- Mod 名称：`[DST]Musha`
- 版本：`T 14.2.4`
- 类型：DST 服务端角色 Mod，`server_only_mod = true`，`all_clients_require_mod = true`
- 核心玩法：RPG 等级成长、四态角色形态、主动技能、法力/疲劳/耐力资源、专属装备成长、伴侣/召唤物、独立 UI、怪物难度强化、多语言文本。
- 当前目录已使用 Git 管理。改动前后应查看 `git status`，但不要回滚用户未要求回滚的改动。

## 本地 Skill 调用

本机已有 DST 人物模组开发 skill：`$dst-character-mod-development`。当需求涉及 Musha 或其他 DST 人物 Mod 的开发、修复、审查、重构、测试、日志排查或创意工坊发布时，用户可以在消息里显式写上 `$dst-character-mod-development`，以强制启用该通用检查清单。

`AGENTS.md` 负责记录本项目事实、目录索引、本机路径、历史踩坑点和 Musha 特有约束；`$dst-character-mod-development` 负责通用 DST 人物 Mod 开发方法。两者重复时，以本文件里的 Musha 项目约束和本机路径为准。

## 文档优先入口

本项目已经在 `docs/` 下整理了较完整的功能说明和代码索引。处理任何需求时，优先把 `docs/` 当作入口和导航，不要直接从几千行 Lua 文件盲找。

推荐阅读顺序：

1. `docs/00_架构总览.md`：项目全局结构、模块依赖、核心风险。
2. `docs/01_配置与入口.md`：`modinfo.lua` 配置项、`modmain.lua` 加载顺序、RPC、PostInit 索引。
3. 根据任务类型阅读对应专题文档。
4. 根据文档里的文件/函数索引进入代码定位。
5. 如果代码行为和文档不一致，以代码为准，并在完成改动后同步修正文档。

## docs/ 功能索引

- `docs/00_架构总览.md`：整体架构、模块地图、主要技术债和高风险区域。
- `docs/01_配置与入口.md`：Mod 配置、快捷键、难度配置、入口加载顺序、RPC 注册、原版 prefab 修改。
- `docs/02_资源声明.md`：`PrefabFiles`、动画、贴图、音效等资源声明。
- `docs/03_角色属性与状态.md`：Musha 基础属性、四态切换、组件、NetVar、核心状态标记。
- `docs/04_等级与经验系统.md`：角色等级、击杀/进食经验、等级里程碑、装备等级、伴侣经验共享。
- `docs/05_技能系统.md`：闪电、冰风暴、强力攻击、暗影、护盾、音乐/嗅探、睡眠、被动技能、施法状态图。
- `docs/06_法力疲劳耐力系统.md`：`spellpower`、`fatigue_sleep`、`stamina_sleep` 三条资源组件与 UI 同步。
- `docs/07_装备系统.md`：武器、护甲、帽子、装备成长、耐久、专属装备限制。
- `docs/08_伴侣与召唤物.md`：Arong、Yamche、Dall、月龙、幽灵犬、暗影分身、保镖、小 Musha。
- `docs/09_物品与材料.md`：材料、食物、特殊物品、掉落和使用方式。
- `docs/10_UI与界面.md`：资源 Badge、HUD 注入、快捷键 UI、原版 UI 覆盖风险。
- `docs/11_配方系统.md`：合成标签、配方材料、难度差异、builder tag。
- `docs/12_行为与状态图.md`：玩家扩展状态、实体 StateGraph、动作状态衔接。
- `docs/13_AI行为树.md`：伴侣和召唤物 Brain 行为逻辑。
- `docs/14_世界物件.md`：建筑、植物、世界实体和生成逻辑。
- `docs/15_难度系统.md`：怪物强化档位、倍率、标签、全服影响。
- `docs/16_本地化.md`：中英韩俄文本、手动语言配置、台词和物品名。

## 代码定位规则

文档用于索引，代码用于最终确认。常见代码入口如下：

- 配置和入口：`docs/01_配置与入口.md` → `modinfo.lua`、`modmain.lua`
- Mod 配置维护：`modinfo_src/` → `tools/build_modinfo.ps1` → `modinfo.lua`
- 资源：`docs/02_资源声明.md` → `scripts/prefabasset.lua`
- 角色主体：`docs/03_角色属性与状态.md` → `scripts/prefabs/musha.lua`
- 等级经验：`docs/04_等级与经验系统.md` → `scripts/prefabs/musha.lua`
- 技能：`docs/05_技能系统.md` → `scripts/musha/skills/`、`scripts/mypower_musha_1.lua`、`scripts/musha_adds_states.lua`
- 三条资源：`docs/06_法力疲劳耐力系统.md` → `scripts/components/`、`scripts/widgets/`
- 装备：`docs/07_装备系统.md` → `scripts/prefabs/mushasword*.lua`、`armor_musha*.lua`、`hat_m*.lua`
- 伴侣/召唤物：`docs/08_伴侣与召唤物.md` → `scripts/prefabs/`、`scripts/brains/`、`scripts/stategraphs/`
- UI：`docs/10_UI与界面.md` → `scripts/widgets/`、`data/screens/`、`data/widgets/controls.lua`
- 配方：`docs/11_配方系统.md` → `scripts/musha_adds_recipe.lua`
- 难度：`docs/15_难度系统.md` → `scripts/difficulty_monster_dst.lua`
- 本地化：`docs/16_本地化.md` → `scripts/strings_musha_*.lua`、`scripts/speech_musha_*.lua`

## 本机常用排查路径

这些路径是当前维护环境的本机约定，用于快速排查日志和其他服务器 Mod；如果以后 Steam 库或 DST 存档集群位置变化，应先重新确认路径。

### DST 日志

- 客户端日志：`C:\Users\29019\Documents\Klei\DoNotStarveTogether\client_log.txt`
- 地面服务器日志：`C:\Users\29019\Documents\Klei\DoNotStarveTogether\441134002\Cluster_1\Master\server_log.txt`
- 洞穴服务器日志：`C:\Users\29019\Documents\Klei\DoNotStarveTogether\441134002\Cluster_1\Caves\server_log.txt`
- 地面聊天日志：`C:\Users\29019\Documents\Klei\DoNotStarveTogether\441134002\Cluster_1\Master\server_chat_log.txt`
- 洞穴聊天日志：`C:\Users\29019\Documents\Klei\DoNotStarveTogether\441134002\Cluster_1\Caves\server_chat_log.txt`
- Klei 根目录下也可能有快捷日志副本：`master_server_log.txt`、`caves_server_log.txt`、`client_log.txt`。排查崩溃时优先看 `Cluster_1\Master` 和 `Cluster_1\Caves` 下的真实分片日志；如果日志为空或刚被轮换，再看快捷副本和按 `LastWriteTime` 搜索最新日志。

当用户说“根据日志分析”“地面崩溃”“洞穴崩溃”时，默认先检查以上日志里的 `stack traceback`、`LUA ERROR`、`attempt to`、`nil value`、`strict.lua`、`Could not find anim build`、`Can't find prefab`、`component ... already exists` 等关键字。

### 外部 Workshop 模组

- 服务器 Workshop 模组父目录：`E:\SteamLibrary\steamapps\workshop\content\322330`
- 用户只给模组 ID 时，默认映射到：`E:\SteamLibrary\steamapps\workshop\content\322330\<mod_id>`
- DST 日志里经常显示为 `../mods/workshop-<mod_id>`，但磁盘上的 Steam Workshop 内容目录通常是纯数字 `<mod_id>`。
- 分析其他服务器 Mod 时，优先读该目录下的 `modinfo.lua`、`modmain.lua`、相关 `scripts/` 文件；除非用户明确要求，不要直接修改 Workshop 订阅目录，因为 Steam 更新可能覆盖这些改动。

## Musha 项目补充约束

通用 DST 人物 Mod 原则交给 `$dst-character-mod-development`。本文件只保留 Musha 项目里更容易踩坑的补充规则：

- 修改 `.lua` 后仍必须执行 `luac -p`；修改 `modinfo_src/` 后先运行 `tools/build_modinfo.ps1`，再检查生成的 `modinfo.lua`。
- Lua 文件必须 UTF-8 无 BOM。入口文件 BOM 会导致 `unexpected symbol near '�'` 并禁用整个模组。
- 拆 `require("xxx")` 模块时，不要让模块隐式依赖 `modmain.lua` 局部变量；需要的 `STRINGS`、`TUNING`、`TheSim`、`SpawnPrefab` 等优先由入口显式传入。
- RPC 命名空间当前主要为 `musha`；新增 RPC 要有服务端校验，不要只做客户端表现。
- 保存字段、prefab 名、组件名、NetVar、配置 key 默认不改名。必须改时要兼容旧存档。
- 调整平衡数值时说明影响范围，尤其是早中后期、Boss 战、多人服务器和非 Musha 玩家。

## 伴侣与召唤物踩坑点

详细通用规则见 `$dst-character-mod-development` 的 `references/companions.md`、`references/character_save_sync.md` 和 `references/testing_release.md`。Musha 侧额外记住：

- Yamche、Dall、Arong、kkobong 曾多次暴露命令态、自然态、leader/follower、跨世界迁移和死亡路径问题；动这些逻辑时必须按 skill 的伴侣清单验证。
- 优先复用 `scripts/musha/companions/states.lua` 和 `scripts/musha/companions/commands.lua`，不要在 `modmain.lua` 里重新堆大段查找和跟随逻辑。
- 多人场景只允许当前主人影响宠物状态，避免“附近任意 Musha”改变休息、召回、攻击或传送。
- Dall/kkobong、Arong 和凤凰相关改动必须覆盖：地上/洞穴双向切换、保存重进、休息/跟随切换、死亡/移除、主人死亡或变鬼。

## 修改高风险区域

这些区域改动前必须先定位调用链，改动后必须重点验证：

- `modmain.lua`：入口加载顺序、模块注册、语言加载和角色注册集中在此；调整时必须确认 require/modimport 顺序。
- `modinfo.lua`：DST 运行时读取的生成文件。不要手改配置项，改 `modinfo_src/` 后运行 `tools/build_modinfo.ps1`。
- `scripts/prefabs/musha.lua`：角色核心文件，影响等级、形态、技能、保存、按键。
- `data/screens/` 与 `data/widgets/controls.lua`：同名 UI Hook，容易与游戏更新或其他 Mod 冲突。
- `scripts/difficulty_monster_dst.lua`：影响全服怪物，不仅影响 Musha。
- `scripts/musha_adds_container.lua`：容器布局定义；冰霜护甲与额外背包显示互斥逻辑在 `scripts/musha/equipment/inventory_overflow.lua`。
- 装备成长 prefab：改动伤害、耐久、保存字段会影响已有装备。

## 工作流程

1. 先读 `docs/00_架构总览.md`、`docs/01_配置与入口.md` 和对应专题文档，再进代码。
2. 需要通用检查清单时启用 `$dst-character-mod-development`，按对应 reference 验证存档、联机、资源、UI、兼容和日志风险。
3. 限定本次改动范围，不借小修复做无关重构。
4. 改代码后同步必要文档；改 Lua 后跑 `luac -p` 并在汇报中写明。
5. 无法实机验证时明确说明；能实机验证时给玩家可执行的测试清单。

## 输出风格

- 用中文回复，除非用户明确要求其他语言。
- 直接说明结论和具体改动，不写泛泛的软件工程套话。
- 遇到风险要明确指出，尤其是存档、联机同步、全服怪物、原版 UI 覆盖。
- 如果只做文档或分析，不要假装已经实机验证。
