<div align="center">

# F50 · OpenWrt

**中兴 F50（MU300）5G 随身路由器固件 · WireGuard · Cloudflare DDNS**

[![OpenWrt](https://img.shields.io/badge/OpenWrt-25.12.6-orange?style=flat-square)](https://openwrt.org/)
[![Linux](https://img.shields.io/badge/Linux-6.18.60-blue?style=flat-square)](https://github.com/dikeckaan/mu300-linux/releases/tag/v2026.11.02.1)
[![Release](https://img.shields.io/badge/Release-v2026.11.20.2-informational?style=flat-square)](https://github.com/Quan-0505/f50-openwrt/releases/tag/v2026.11.20.2)
[![Downloads](https://img.shields.io/github/downloads/Quan-0505/f50-openwrt/total?style=flat-square)](https://github.com/Quan-0505/f50-openwrt/releases)

[固件下载](#downloads) · [离线升级](#upgrade) · [实机验证](#validation) · [配置与构建](#build) · [上游文档](README.upstream.md)

</div>

---

## 功能特性

- **OpenWrt 25.12.6 + Linux 6.18.60**：基于 [MU300 Linux v2026.11.02.1](https://github.com/dikeckaan/mu300-linux/releases/tag/v2026.11.02.1)，沿用上游内核。
- **WireGuard**：内核已内建支持，镜像包含命令行工具和 LuCI 插件，可配置公网 IPv6 对端。
- **daed 面板入口**：镜像包含基于 [DaedNext](https://github.com/ksong008/DaedNext) 的 ARM64 Rust daed 3.2.2、Web 面板与 Geo 数据。全新安装默认不启动；配置好后可在 SSH 运行 `/etc/init.d/daed enable` 和 `/etc/init.d/daed start`，再通过 LuCI 的「服务 → daed」打开面板。
- **Cloudflare DDNS**：预装 LuCI 动态 DNS、Cloudflare 支持和简体中文包。DDNS 默认关闭，启用前需填写自己的域名和凭据。

<a id="downloads"></a>

## 固件下载

当前版本：[v2026.11.20.2](https://github.com/Quan-0505/f50-openwrt/releases/tag/v2026.11.20.2) · **未签名预发布** · 适用中兴 F50（MU300 / UMS9620）。

| 格式 | 下载 | 适用场景 |
| --- | --- | --- |
| ext4 | [ext4 ZIP](https://github.com/Quan-0505/f50-openwrt/releases/download/v2026.11.20.2/F50-OpenWrt-2026-11-20.2-25.12.6-ext4.zip) | 推荐。解压后可交给原生离线更新器，升级流程已在上一版实机验证。 |
| SquashFS | [SFS ZIP](https://github.com/Quan-0505/f50-openwrt/releases/download/v2026.11.20.2/F50-OpenWrt-2026-11-20.2-25.12.6-sfs.zip) | 只读根文件系统归档。需在 Linux 上转换；已验证转换，未单独刷机。 |

两个 ZIP 均含 `SHA256SUMS`。它们是离线更新包，不是 Magisk 安装包。

<a id="upgrade"></a>

## 离线升级

以下流程用于**已经运行 MU300 OpenWrt LuCI 的 F50**。首次安装请先阅读[上游安装文档](README.upstream.md)。

1. 备份设备配置，保持供电和 USB 连接。下载并解压 ext4 ZIP，将整个目录复制到 F50。
2. 在 F50 的 SSH 终端核对校验值，并用原生更新器检查。把下例目录换成实际路径。
   ```sh
   cd /mnt/mu300-disk/f50-update
   sha256sum -c SHA256SUMS && mu300-update inspect "$PWD"
   ```
3. 确认预发布版本、设备及可用空间均符合预期后，执行离线升级。等待更新器提示完成，再重启。
   ```sh
   mu300-update apply --from "$PWD" --unsigned openwrt-luci
   ```

SFS ZIP 解压后，先在 Linux 上安装 `squashfs-tools`，运行 `sudo sh ./prepare-offline-update.sh ./offline-update`，再将生成的目录用于上述步骤。若需回退系统，使用 `mu300-update rollback openwrt-luci`，按提示重启。

<a id="validation"></a>

## 实机验证

`v2026.11.20.2` 已校验固件包，尚未刷机。此前，一台 F50 从上游 `v2026.11.02.1` 实机升级到 `v2026.11.19.1` 并正常启动；USB 网络、SSH、LuCI 登录页正常，原有 6 个附加软件包恢复。WireGuard 到三家 OPNsense 和 U60 的直连通过，设备保留上游版供回退。

首次开机时 DNS 尚未就绪。本次在重启 DDNS 服务后确认 Cloudflare AAAA 更新；自动恢复时延尚未验证。SFS 版只做了解包和转换比对。

<a id="build"></a>

## 配置与构建

- [WireGuard 与 DDNS 配置](docs/f50-wireguard-ddns.md)：站点互联、IPv6 端点与 Cloudflare 设置。
- [构建配方](openwrt/build-rootfs.sh) · [上游构建文档](docs/BUILD.md)：OpenWrt 包由镜像配方选入。当前预发布在上游已验签的 LuCI 镜像中加入 DDNS 包后重新封装；[daed 集成脚本](tools/f50-add-daed.sh) 从固定校验值的 [ARM64 发布包](https://github.com/Quan-0505/rust-daed/releases/tag/v3.2.2) 加入程序和 Web 资源。daed 的[对应源码及许可证](https://github.com/Quan-0505/rust-daed/tree/v3.2.2)见原仓库。

## 上游与许可证

感谢 [dikeckaan/mu300-linux](https://github.com/dikeckaan/mu300-linux) 的设备支持、内核和工具。完整原版说明见 [README.upstream.md](README.upstream.md)，许可见 [LICENSE](LICENSE)。
