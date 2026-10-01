# CẨM NANG & BỘ CẤU HÌNH TÙY BIẾN TOÀN DIỆN ARCH LINUX + KDE PLASMA 6

> **Dành cho ThinkPad E490 / Arch Linux x86_64**  
> Dự án chứa toàn bộ mã nguồn cấu hình, giao diện, widget, font chữ, bố cục panel, phím tắt, terminal và các thiết lập tối ưu máy tiết kiệm pin & hiệu năng cực đại.


![Screenshot](./assets/screenshots/Screenshot.png)
---

## MỤC LỤC
1. [Khôi phục giao diện như cũ chỉ với 1 lệnh](#1-khôi-phục-giao-diện-như-cũ-chỉ-với-1-lệnh)
2. [Cấu trúc thư mục dự án](#2-cấu-trúc-thư-mục-dự-án)
3. [Chi tiết toàn bộ các thành phần đã được tùy biến](#3-chi-tiết-toàn-bộ-các-thành-phần-đã-được-tùy-biến)
   - [Giao diện & Chủ đề (Theme & Colors)](#a-giao-diện--chủ-đề-theme--colors)
   - [Bố cục Thanh Panel & Widgets](#b-bố-cục-thanh-panel--widgets)
   - [Font chữ & Độ mịn màn hình](#c-font-chữ--độ-mịn-màn-hình)
   - [Hiệu ứng cửa sổ KWin & Tiling](#d-hiệu-ứng-cửa-sổ-kwin--tiling)
   - [Phím tắt thao tác nhanh (Keybindings)](#e-phím-tắt-thao-tác-nhanh-keybindings)
   - [Terminal Kitty & Shell Zsh](#f-terminal-kitty--shell-zsh)
   - [Bộ gõ tiếng Việt](#g-bộ-gõ-tiếng-việt)
   - [Tối ưu hóa Pin & Hiệu năng ThinkPad](#h-tối-ưu-hóa-pin--hiệu-năng-thinkpad)
4. [Hướng dẫn sao lưu cập nhật khi có thay đổi mới](#4-hướng-dẫn-sao-lưu-cập-nhật-khi-có-thay-đổi-mới)
5. [Cài đặt trên một máy mới hoàn toàn (Clean Install)](#5-cài-đặt-trên-một-máy-mới-hoàn-toàn-clean-install)
6. [Khắc phục sự cố thường gặp (Troubleshooting)](#6-khắc-phục-sự-cố-thường-gặp-troubleshooting)

---

## 1. KHÔI PHỤC GIAO DIỆN NHƯ CŨ CHỈ VỚI 1 LỆNH

Khi bạn lỡ tay xóa mất panel, giao diện bị vỡ, font chữ bị đổi, hoặc bạn muốn đưa mọi thứ về trạng thái hoàn hảo như lúc ban đầu:

### Bước 1: Mở Terminal lên và di chuyển vào thư mục này:
```bash
cd ~/Desktop/linux-customizations
```

### Bước 2: Chạy script khôi phục:
```bash
./restore.sh
```
*(Script sẽ tự động sao lưu cấu hình hiện tại vào `~/.config.backup.<thời_gian>` để đảm bảo 100% an toàn dữ liệu trước khi khôi phục).*

### Các tùy chọn nâng cao khi chạy `restore.sh`:
- `./restore.sh --all` : Khôi phục tất cả tự động (Giao diện, Font, Hình nền, Tối ưu hệ thống /etc).
- `./restore.sh --ui` : Chỉ khôi phục giao diện, bố cục panel, widgets, font và terminal (không đụng chạm tới /etc, không cần mật khẩu root).
- `./restore.sh --fonts` : Chỉ cài đặt lại font chữ và làm mới bộ nhớ đệm font.
- `./restore.sh --system` : Chỉ áp dụng các cấu hình tối ưu pin và hiệu năng hệ thống `/etc`.

> **Mẹo:** Sau khi khôi phục xong, hãy **Đăng xuất (Log Out)** và đăng nhập lại, hoặc khởi động lại máy để toàn bộ font chữ và hiệu ứng kính mờ được áp dụng đồng bộ trên tất cả ứng dụng.

---

## 2. CẤU TRÚC THƯ MỤC DỰ ÁN

```
linux-customizations/
├── README.md                      # Cẩm nang hướng dẫn sử dụng chi tiết (tệp này)
├── restore.sh                     # Script 1-click tự động khôi phục mọi thứ như cũ
├── backup.sh                      # Script 1-click tự động cập nhật / đồng bộ tùy biến mới vào project
├── config/                        # Toàn bộ tệp cấu hình ~/.config
│   ├── kdeglobals                 # Cấu hình màu Catppuccin, font SF Pro, màu nhấn Mauve tím
│   ├── kwinrc                     # Hiệu ứng KWin (Wobbly, Blur, Night Color, Tiling layout)
│   ├── kwinrulesrc                # Quy tắc hiển thị cửa sổ
│   ├── kwinoutputconfig.json      # Cấu hình đa màn hình (Màn ThinkPad + Màn rời DP-1 100Hz)
│   ├── plasmarc                   # Theme Plasma (Ant-Dark)
│   ├── plasmashellrc              # Shell Plasma
│   ├── plasma-org.kde.plasma.desktop-appletsrc # Cấu trúc thanh panel trên và các widget
│   ├── darklyrc                   # Độ trong suốt và làm mờ của Darkly Style
│   ├── kdedefaults/               # Liên kết mặc định các thành phần giao diện
│   ├── kcminputrc                 # Con trỏ chuột Bibata-Modern-Ice và cảm ứng touchpad
│   ├── kscreenlockerrc            # Màn hình khóa
│   ├── ksplashrc                  # Màn hình khởi động Splash screen (Catppuccin_Final)
│   ├── kglobalshortcutsrc         # Danh sách phím tắt hệ thống
│   ├── fontconfig/                # Khử răng cưa font: Subpixel RGB, Hinting, LCD Filter
│   ├── kitty/                     # Cấu hình Kitty Terminal + Catppuccin Mocha theme
│   ├── fastfetch/                 # Cấu hình Fastfetch
│   ├── fcitx5/                    # Cấu hình bộ gõ Fcitx5 (nếu dùng song song)
│   ├── gtk-3.0/ & gtk-4.0/        # Đồng bộ giao diện ứng dụng GTK với KDE
│   ├── easyeffects/               # Bộ cân bằng âm thanh Equalizer
│   └── hypr/                      # Quickshell color palette cho banner terminal
├── home/                          # Các tệp cấu hình trực tiếp tại thư mục $HOME
│   ├── .zshrc                     # Cấu hình Zsh với Fastfetch banner động + smart cd
│   ├── .p10k.zsh                  # Theme Powerlevel10k phong cách Apple/Modern
│   ├── .gtkrc-2.0                 # Cấu hình giao diện GTK2 cũ
│   ├── .gitconfig                 # Thông tin cấu hình Git cá nhân
│   ├── .face                      # Ảnh đại diện người dùng trên màn hình khóa
│   └── .face.icon                 # Icon đại diện tài khoản
├── local_share/                   # Tài nguyên giao diện ~/.local/share
│   ├── fonts/                     # Toàn bộ font: SF-Pro, JetBrainsMono, AnnotationMono, Iosevka
│   ├── icons/                     # Con trỏ chuột Bibata và bộ icon Papirus-Dark, Breeze-Noir, candy
│   ├── color-schemes/             # Bảng màu Catppuccin Mocha colors
│   ├── aurorae/                   # Chủ đề viền cửa sổ Otto
│   ├── plasma/                    # Desktoptheme (Ant-Dark), Look-and-Feel, Plasmoids (Widgets)
│   └── easyeffects/               # Preset âm thanh live_eq.json
├── system/                        # Cấu hình tối ưu máy cấp độ hệ thống (/etc)
│   ├── tlp.d/                     # Cấu hình tiết kiệm pin ThinkPad cực đại
│   ├── modprobe.d/                # Cấu hình GPU Intel i915 FBC + PSR tiết kiệm điện
│   ├── environment                # Tinh chỉnh độ nét font Freetype stem-darkening
│   ├── pacman.conf                # Pacman 5 luồng tải, giao diện màu sắc, multilib
│   ├── makepkg.conf.snippet       # Tối ưu hóa compile gói phần mềm đa luồng
│   ├── zram-generator.conf        # Cấu hình ZRAM RAM ảo nén zstd 4GB
│   └── services-list.txt          # Danh sách lệnh bật/tắt dịch vụ hệ thống
├── assets/                        # Hình nền & Biểu tượng nút bấm
│   ├── wallpapers/                # Hình nền mèo mây cat-in-clouds.png, clouds-5, panes, river-city
│   └── icons/                     # Icon SVG Control Centre
└── packages/                      # Quản lý gói phần mềm
    ├── pkglist-repo.txt           # Danh sách 149 gói chính thức của hệ thống Arch Linux
    ├── pkglist-aur.txt            # Danh sách các gói AUR đã cài (yay)
    └── darkly/                    # Toàn bộ mã nguồn Darkly Window Decoration sẵn sàng build
```

---

## 3. CHI TIẾT TOÀN BỘ CÁC THÀNH PHẦN ĐÃ ĐƯỢC TÙY BIẾN

### A. Giao diện & Chủ đề (Theme & Colors)
- **Plasma Look-and-Feel:** `Catppuccin_Final`
- **Plasma Desktop Theme:** `Ant-Dark` (Tối hiện đại, thanh thoát, bo góc mịn)
- **Bảng màu (Color Scheme):** `Catppuccin Mocha` với màu nhấn (Accent Color) là màu tím mộng mơ (Mauve `#926ee4` / RGB `146, 110, 228`).
- **Ứng dụng & Viền cửa sổ (Application & Window Style):** `Darkly`
  - Tích hợp kính mờ trong suốt (Blur & Transparency) với độ mờ 60% trên thanh Sidebar và View của Dolphin, Menu bar, Tab bar.
  - Viền cửa sổ không có viền thừa (Borderless `BorderSize=None`), tạo cảm giác vô cực thanh thoát.
- **Biểu tượng (Icon Theme):** `Papirus-Dark` sắc nét trên nền tối.
- **Con trỏ chuột (Cursor Theme):** `Bibata-Modern-Ice` kích thước 24px sang trọng.
- **Hình nền mặc định:** `cat-in-clouds.png` (Hình chú mèo ngồi ngắm trăng giữa những tầng mây êm dịu).

---

### B. Bố cục Thanh Panel & Widgets
- **Vị trí Panel:** Đặt ở **Cạnh trên cùng (Top Panel)** với chế độ hiển thị nổi bo góc.
- **Các thành phần trên Panel (từ trái qua phải):**
  1. `org.kde.plasma.kickoff` : Menu ứng dụng góc trái.
  2. `org.kde.plasma.windowlist` : Danh sách chuyển đổi cửa sổ nhanh.
  3. `KdeControlStation` : Trung tâm điều khiển trung tâm (Control Center) với icon điều khiển tùy biến, tích hợp chuyển chế độ pin, âm lượng, độ sáng, Wi-Fi.
  4. `org.kde.plasma.panelspacer` : Khoảng trống đẩy đồng hồ ra giữa.
  5. `com.github.N0repi.compactclock` / `modernclock` : Đồng hồ hiển thị ngày tháng năm tối giản giữa màn hình.
  6. `org.kde.plasma.panelspacer` : Khoảng trống đẩy khay hệ thống sang phải.
  7. `org.kde.plasma.icontasks` : Thanh công cụ gom nhóm ứng dụng theo icon.
  8. `org.kde.plasma.systemtray` : Khay hệ thống thu gọn.
  9. `org.kde.plasma.showdesktop` : Nút thu nhỏ tất cả để về desktop.
- **Widget trên Desktop:**
  - `Music.Waves` : Sóng âm thanh chuyển động theo giai điệu nhạc đang phát.
  - `com.github.prayag2.modernclock` : Đồng hồ phong cách hiện đại.
- **Cấu hình đa màn hình:** Tự động nhận diện màn hình gốc ThinkPad (1366x768 @ 60Hz) và màn hình rời mở rộng DP-1 (1920x1080 @ 100Hz mượt mà).

---

### C. Font chữ & Độ mịn màn hình
- **Font giao diện chính:** `SF Pro Display` (Font tiêu chuẩn của Apple macOS/iOS) kích thước 10pt hiển thị cực kỳ dễ chịu cho mắt.
- **Font thanh Menu, Công cụ, Tiêu đề:** `SF Pro Display` 10pt.
- **Font chữ nhỏ (Smallest):** `SF Pro Display` 8pt.
- **Font mã nguồn / Terminal:**
  - `AnnotationM Nerd Font Mono` (sử dụng trong Kitty).
  - `JetBrains Mono` & `Iosevka Nerd Font` (sẵn sàng cho code editor / Neovim).
- **Tinh chỉnh hiển thị sắc nét:**
  - File `~/.config/fontconfig/fonts.conf`:
    - Khử răng cưa `antialias = true`.
    - Dạng hiển thị điểm ảnh `rgba = rgb` (chuẩn màn hình máy tính).
    - Tinh chỉnh ký tự `hinting = true`, `hintstyle = hintslight` cho nét chữ mềm mại tự nhiên.
    - Bộ lọc viền màu `lcdfilter = lcddefault`.
  - File `/etc/environment`:
    - `FREETYPE_PROPERTIES="cff:no-stem-darkening=0 autofitter:no-stem-darkening=0"` loại bỏ hiện tượng chữ bị đậm quá mức trên Linux.

---

### D. Hiệu ứng cửa sổ KWin & Tiling
- **Wobbly Windows:** Cửa sổ rung rinh dạng jelly mềm mại khi di chuyển hoặc kéo thả.
- **Blur & Translucency:** Nền kính mờ với độ bão hòa màu 225 (`Saturation=225`) và khử nhiễu (`NoiseStrength=0`).
- **Night Color (Lọc ánh sáng xanh):** Tự động điều chỉnh nhiệt độ màu về `3300K` vào ban đêm để bảo vệ thị lực và giấc ngủ.
- **Chia cột tự động (Tiling Window Manager):**
  - Bố cục 3 cột tỷ lệ vàng: **25% | 50% | 25%** (Cột giữa rộng cho công việc chính, 2 cột bên cho ghi chú và terminal).
  - Khoảng cách viền lề (padding) cửa sổ là `4px`.

---

### E. Phím tắt thao tác nhanh (Keybindings)
| Phím tắt | Chức năng |
| :--- | :--- |
| `Meta` (Phím Super) / `Alt + F1` | Mở Application Launcher (Menu bắt đầu) |
| `Meta + V` | **Mở lịch sử Clipboard** ngay tại vị trí con trỏ chuột |
| `Meta + 1` đến `Meta + 9` | Mở / Chuyển nhanh giữa các ứng dụng trên thanh Taskbar |
| `Meta + ←` / `Meta + →` | Snap cửa sổ sang nửa màn hình Trái / Phải |
| `Meta + ↑` / `Meta + ↓` | Thu nhỏ hoặc Phóng to toàn màn hình |
| `Meta + Backspace` | Khôi phục lại kích thước cửa sổ bình thường |
| `Meta + Shift + ←` / `→` | Chuyển ngay cửa sổ sang Màn hình phụ / Màn hình chính |
| `Meta + Q` | Bật trình quản lý không gian làm việc (Activities) |
| `Ctrl + F12` | Ẩn hết cửa sổ để xem Desktop |
| `PrintScreen` | Chụp màn hình bằng Spectacle |

---

### F. Terminal Kitty & Shell Zsh
- **Kitty Terminal:**
  - Bảng màu Catppuccin Mocha chính thức.
  - Font chữ: `AnnotationM Nerd Font Mono`.
  - Bo góc và hỗ trợ hiển thị ảnh đồ họa Kitty graphics protocol.
- **Zsh Shell (`~/.zshrc`):**
  - **Dynamic Fastfetch Banner:** Khi mở terminal, tự động trích xuất bảng màu Catppuccin và tạo thanh thông tin phần cứng tối giản cùng dải chấm tròn màu ANSI truecolor (`● ● ● ● ● ● ●`).
  - **Powerlevel10k Prompt:** Theme dòng lệnh thời thượng, hiển thị Git branch, trạng thái thực thi.
  - **Plugins tích hợp:** `zsh-autosuggestions` (tự động gợi ý lệnh tiếp theo mờ mờ), `zsh-syntax-highlighting` (tô màu cú pháp lệnh hợp lệ/sai), `git`.
  - **Smart `cd`:** Tự động chạy `ls` ngay khi vừa `cd` vào bất kỳ thư mục nào.

---

### G. Bộ gõ tiếng Việt
- Sử dụng **IBus-Unikey** tích hợp nguyên bản trên Wayland/Plasma 6:
  - Tự động nạp bộ gõ Wayland: `InputMethod=/usr/share/applications/org.freedesktop.IBus.Panel.Wayland.Gtk3.desktop`.
  - Phím chuyển đổi nhanh: `Ctrl + Shift` hoặc `Super + Space`.

---

### H. Tối ưu hóa Pin & Hiệu năng ThinkPad
Các thiết lập nằm trong thư mục `system/` được tinh chỉnh tối ưu dành riêng cho dòng laptop ThinkPad chạy chip Intel:

1. **Bộ script tối ưu pin cực hạn (`system/setup-battery-saver.sh`):**
   - Script tự động hóa toàn bộ việc cài đặt `tlp`, `powertop`, thiết lập giới hạn công suất Intel RAPL, vô hiệu hóa xung đột và cấu hình ALSA.
   - Có thể chạy độc lập: `sudo bash ~/Desktop/linux-customizations/system/setup-battery-saver.sh`.
2. **Khóa trần công suất CPU Intel RAPL 10W (`/etc/udev/rules.d/99-rapl-battery.rules`):**
   - Tự động nhận diện khi rút sạc (`online=0`): Khóa trần tiêu thụ điện của CPU ở mức **10W** (`10000000 uW`), ngăn ngừa CPU ngốn điện đột biến khi mở app nặng.
   - Khi cắm sạc (`online=1`): Mở lại toàn bộ công suất tối đa **25W** để đạt hiệu năng cao nhất.
3. **Powertop Auto-Tune Service (`/etc/systemd/system/powertop.service`):**
   - Tự động kích hoạt toàn bộ các cờ tiết kiệm điện phần cứng (PCIe, USB, Audio, SATA, CPU) mỗi khi khởi động máy.
4. **TLP (`/etc/tlp.d/00-extreme-battery.conf`):**
   - **Tắt Turbo Boost khi dùng pin (`CPU_BOOST_ON_BAT=0`):** Tiết kiệm đến 40-50% điện năng CPU, giảm nhiệt độ máy đáng kể.
   - **Khóa trần hiệu năng CPU P-state ở mức 60% khi dùng pin (`CPU_MAX_PERF_ON_BAT=60`):** Giữ điện áp CPU luôn ở mức thấp.
   - **Khống chế xung nhịp GPU Intel khi dùng pin:** Min 300MHz, Max 650MHz, Boost 750MHz.
   - **Chế độ năng lượng:** Dùng pin chuyển sang `power`, cắm sạc chuyển sang `balance_performance`.
   - **Tiết kiệm điện bus PCIe (ASPM):** Chuyển sang `powersupersave` khi dùng pin.
   - **Tắt Wake-on-LAN card Ethernet (`WOL_DISABLE=Y`):** Ngăn card mạng Realtek ngốn pin ngầm.
   - **Âm thanh Conexant CX11880:** Bật chế độ nghỉ ngủ DAC sau 1s ngưng phát nhạc khi dùng pin nhưng vẫn giữ PCI controller mở để không bị rè/mất âm thanh PipeWire.
   - **Tắt Bluetooth tự động** khi khởi động máy bằng pin nếu không kết nối thiết bị.
5. **GPU Intel Powersave (`/etc/modprobe.d/i915-powersave.conf`):**
   - Bật Frame Buffer Compression (`enable_fbc=1`) và Panel Self Refresh (`enable_psr=1`) giảm mức tiêu thụ điện màn hình tới mức tối đa.
6. **ZRAM RAM ảo nén zstd 4GB (`/etc/systemd/zram-generator.conf`):**
   - Tạo phân vùng Swap 4GB nén bằng thuật toán zstd siêu tốc ngay trên RAM thật, giúp máy chạy mượt mà ngay cả khi mở nhiều tab trình duyệt, hoàn toàn không gây ghi hại ổ cứng SSD NVMe.
7. **Bảo trì SSD định kỳ (`fstrim.timer`):**
   - Tự động Trim dọn dẹp các khối nhớ thừa trên ổ cứng SSD hàng tuần, giữ tốc độ đọc ghi ổ luôn ở mức cao nhất.
8. **Tối ưu Pacman (`/etc/pacman.conf`):**
   - Mở khóa tải 5 file song song (`ParallelDownloads = 5`), bật màu sắc hiển thị và kho phần mềm `multilib`.
9. **Xử lý xung đột dịch vụ:**
   - Đã `mask power-profiles-daemon` để TLP nắm toàn quyền điều phối điện năng, tránh 2 trình quản lý giằng co làm nóng máy.

---

## 4. HƯỚNG DẪN SAO LƯU CẬP NHẬT KHI CÓ THAY ĐỔI MỚI

Trong quá trình sử dụng, nếu bạn:
- Tải thêm font mới hoặc đổi font chữ khác.
- Kéo thả thêm widget mới lên desktop hoặc thanh taskbar.
- Đổi hình nền máy tính khác.
- Chỉnh sửa phím tắt hoặc cài thêm các ứng dụng mới qua Pacman/AUR.

Bạn chỉ cần mở terminal và chạy:
```bash
cd ~/Desktop/linux-customizations
./backup.sh
```
Script sẽ tự động lấy toàn bộ cấu hình mới nhất trên máy bạn và lưu đè vào thư mục project này.

---

## 5. CÀI ĐẶT TRÊN MỘT MÁY MỚI HOÀN TOÀN (CLEAN INSTALL)

Nếu một ngày bạn cài lại Arch Linux mới tinh trên máy ThinkPad này hoặc máy khác:

1. **Cài đặt các phần mềm chính thức:**
   ```bash
   sudo pacman -S - < ~/Desktop/linux-customizations/packages/pkglist-repo.txt
   ```
2. **Cài đặt các ứng dụng AUR (nếu dùng yay):**
   ```bash
   yay -S - < ~/Desktop/linux-customizations/packages/pkglist-aur.txt
   ```
3. **Biên dịch Darkly (nếu chưa có sẵn):**
   ```bash
   cd ~/Desktop/linux-customizations/packages/darkly
   cmake -B build -S . -DBUILD_QT6=ON -DBUILD_QT5=OFF
   cmake --build build -j$(nproc)
   sudo cmake --install build
   ```
4. **Chạy khôi phục 1-click:**
   ```bash
   cd ~/Desktop/linux-customizations
   ./restore.sh --all
   ```

---

## 6. KHẮC PHỤC SỰ CỐ THƯỜNG GẶP (TROUBLESHOOTING)

### ❓ Khôi phục xong nhưng thanh panel chưa hiện ngay lập tức?
Chạy lệnh sau để khởi động lại shell Plasma:
```bash
systemctl --user restart plasma-plasmashell
```

### ❓ Hiệu ứng viền mờ trong suốt của Darkly chưa nhận?
Vào **System Settings** -> **Colors & Themes** -> **Window Decorations** -> Chọn lại **Darkly** và nhấn **Apply**.

### ❓ Font chữ hiển thị còn mờ hoặc chưa áp dụng lên trình duyệt?
Làm mới lại bộ nhớ đệm font chữ hệ thống:
```bash
fc-cache -fv
```
Sau đó đăng xuất (Log out) tài khoản ra và đăng nhập lại.

---

**Chúc bạn có trải nghiệm làm việc mượt mà, đẹp mắt và tiết kiệm pin tối đa trên Arch Linux!**
