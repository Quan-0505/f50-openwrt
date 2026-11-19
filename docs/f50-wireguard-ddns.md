# F50：WireGuard 与 DDNS

## WireGuard

在 LuCI 的「网络 → 接口」创建 WireGuard 接口（例如 `wg_f50`）。给它分配本站的隧道地址，并为每个需要直连的站点加入一个对端。每个对端只登记它自己拥有的隧道地址和局域网段；对端也需要登记 F50 公钥和 F50 的网段。各站独立握手即可直连。

公网 IPv6 数字端点写成 `[IPv6]:PORT`。使用 DDNS 主机名时，确认设备能在隧道尚未建立时独立解析 AAAA。若当前解析器无法返回 AAAA，先用可信解析器检查，避免依赖隧道内 DNS 建立隧道。确认握手、路由和回程后再转移业务流量。

## Cloudflare DDNS

先在 Cloudflare 为 F50 创建 **仅 DNS** 的 AAAA 记录。在 LuCI 的「服务 → 动态 DNS」添加 IPv6 项，使用 `cloudflare.com-v4`，填写自己的主机名、域名和 API Token。IP 来源选实际取得公网 IPv6 的蜂窝设备；F50 单卡默认通常是 `sipa_eth0`，可通过 `ip -6 route show default` 核对。

API Token 仅授予目标 DNS 区域所需权限。在本机保存，勿提交到 Git。同一条记录只运行一个更新服务。启用后从外部查 AAAA，并与 F50 的公网 IPv6 对比。
