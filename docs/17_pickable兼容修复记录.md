# pickable 组件兼容修复记录

## 根因

`scripts/components/pickable.lua` 与原版同名，通过组件加载路径整份替换引擎实现；`modmain.lua` 无显式导入它。组件加载发生在各个服务端模拟分片，因此 Master 和 Caves 都会使用这份旧实现。DST 759671 的 Vault 房间轮换调用 `pickable:SetStuck()`，旧副本没有该方法，导致 Caves 的 `RotateRoomsTick` 报错并断开。

原版比仓库副本不止多一个方法：当前原版还包含 `SpawnProductLoot`，在 `Pick` 中拒绝采集 `stuck` 对象，并在 `OnSave`/`OnLoad` 保存和恢复 `stuck`。原版 `Pick` 返回采集结果供调用方使用，移除组件覆盖后也恢复该接口。因而仅补 `SetStuck` 会继续保留整份过期组件和 API 漂移风险。

## 改动

- 删除完整的旧 `scripts/components/pickable.lua` 覆盖，让 DST 759671 提供组件、字段、保存/加载和事件行为。
- 新增 `scripts/musha/world/pickable_compat.lua`：通过 `AddComponentPostInit` 链式包装原版 `SpawnProductLoot`，只对带 `yamcheb` 标签或 `critter_musha` 标记且具有 `container` 的 Musha 伴侣，把采集产物放入容器；其他采集者继续调用当前组件原实现。
- 原版 `SetStuck`/`IsStuck` 保持 `self.stuck = stuck` 与 `self.stuck == true` 语义；stuck 继续阻止采集，并通过原版保存字段跨存档保留。旧存档没有 `stuck` 字段时自然按 false 处理。

## 搜索与验证

- 对照本机 `Don't Starve Together/data/databundles/scripts.zip` 中 `scripts/components/pickable.lua`，游戏版本文件为 `759671`。
- 仓库范围全局搜索 `SetStuck`、`IsStuck`、`components.pickable` 和 `pickable.lua`；未发现其他 Musha 代码调用 `pickable:SetStuck`。现存 `IsStuck` 在状态图中作用于 `pinnable`，与本修复没有接口冲突。
- `luac -p modmain.lua scripts/musha/world/pickable_compat.lua`：通过；本机解析器为 Lua 5.4.8。项目 skill 的严格检查器要求 Lua 5.1.x，因此将 5.4 标记为“未验证”，不能把它当成 DST 目标版本语法证据。
- 仓库仅有的自动化测试 `lua tools/tests/test_frosthammer_mode.lua`：通过；它与 pickable 无关。仓库没有 pickable 专项测试。
- `git diff --check`、修改 Lua 文件 UTF-8 无 BOM 检查：通过。
- 洞穴轮换实机验证：未执行。虽然安装了 DST 759671，但没有现成的隔离测试分片；启动当前分片会触碰玩家世界存档，而本次明确禁止修改存档，也禁止创建临时测试存档。

## 兼容性与剩余风险

- 修改不增加、删除或重命名存档字段；旧 Musha 角色与世界存档兼容风险低。
- 运行时采集逻辑恢复当前 DST 原版实现，只对 Musha 伴侣的目标采集产物做增量路由。第三方模组仍可链式包装原版方法；多模组组合、伴侣容器采集和真实 Vault 轮换仍需在独立且允许使用的测试世界验证，预期 Caves 保持连接且地下入口继续可用，日志不再出现 `vault_switch.lua:74 SetStuck`。
- 发布维护版更新后需要同步上传 Workshop，玩家/服务器需安装相同版本；工作区修改本身不会自动更新已安装的 Workshop 文件。
