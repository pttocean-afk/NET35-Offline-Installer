# .NET Framework 3.5 Offline Installer

> DISM-based offline installer for Windows 10 / 11 — no internet connection required.

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)](https://github.com/pttocean-afk/NET35-Offline-Installer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Stars](https://img.shields.io/github/stars/pttocean-afk/NET35-Offline-Installer?style=flat)

---

## 原理

Windows 安裝光碟的 `sources\sxs` 資料夾中已有 .NET 3.5 的 CAB 檔。
透過 DISM 指定本機來源即可離線啟用，不需連 Windows Update 等待。

## 檔案結構

```
NET35-Offline-Installer/
├── install.bat                    ← 點兩下以系統管理員執行
├── build_offline_package.ps1      ← 自動從 Windows ISO 取出 sxs
├── README.md
├── Win10_22H2/sxs/                ← (使用者自行準備)
└── Win11_25H2/sxs/                ← (使用者自行準備)
```

## 使用方法

### 一般安裝

1. **下載** 本專案的最新版本
2. **準備 sxs 來源**（見下方說明）
3. 對 `install.bat` 按右鍵 → **以系統管理員身分執行**
4. 完成！

### install.bat 會自動：

- 檢查 .NET 3.5 是否已安裝 → 已裝則跳過
- 偵測 Windows 10 / 11 版本
- 從對應的 `sxs` 資料夾離線啟用 NetFx3
- 若離線失敗 → 自動 fallback 到 Windows Update

## 如何取得 sxs

### 方法一：從 Windows ISO 抽取（建議）

1. 下載 Windows ISO：
   - [Windows 10](https://www.microsoft.com/software-download/windows10)
   - [Windows 11](https://www.microsoft.com/software-download/windows11)
2. 掛載 ISO（右鍵 → 掛載）
3. 複製 `sources\sxs` 整個資料夾
4. 貼到對應版本目錄下

### 方法二：用 extract script 自動取出

以系統管理員執行 PowerShell：

```powershell
.\build_offline_package.ps1
```

- 自動掃描 `Downloads` 中的 `Win*.iso`
- 自動掛載 → 偵測版本 → 複製 sxs → 卸載 ISO
- 支援 Windows 10 / 11 多版本偵測

## 常見問題

**Q: DISM 報錯「找不到來源」？**
A: sxs 版本與 Windows 版本不合，腳本會自動轉 Windows Update 安裝。

**Q: 可以放隨身碟嗎？**
A: 可以。`install.bat` 使用相對路徑，放在任何位置都能跑。

**Q: 為什麼不用微軟的離線安裝包？**
A: 微軟官方離線包（NDP35.exe）僅支援舊版 Windows；Windows 10/11 需透過 DISM 啟用功能。

## 支援的 Windows 版本

| Windows | 版本 | 備註 |
|---------|------|------|
| Windows 10 | 22H2 (build 19045) | 最終穩定版 |
| Windows 11 | 25H2 | 最新版 |

其他版本也相容 — 若 sxs 版本不合，腳本會自動走 Windows Update。

## License

MIT
