#!/usr/bin/env bash
# ==============================================================================
# Script Khôi Phục Toàn Diện Giao Diện & Tối Ưu Hóa Arch Linux + KDE Plasma 6
# Tác giả: nguyendinhkhanh
# Mô tả: Tự động khôi phục cấu hình giao diện, font chữ, bố cục panel, widget,
#        hiệu ứng KWin, terminal kitty, shell zsh và các thiết lập tối ưu máy.
# ==============================================================================

set -e

# Màu sắc hiển thị
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Thư mục gốc của project
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"

print_banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "======================================================================"
    echo "   ARCH LINUX & KDE PLASMA 6 - FULL CUSTOMIZATION RESTORE WIZARD      "
    echo "======================================================================"
    echo -e "${NC}"
    echo -e "${CYAN}Thư mục nguồn:${NC} $SCRIPT_DIR"
    echo -e "${CYAN}Người dùng hiện tại:${NC} $USER ($HOME)"
    echo -e "${CYAN}Thời gian:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    echo "----------------------------------------------------------------------"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[CẢNH BÁO]${NC} $1"
}

log_step() {
    echo ""
    echo -e "${PURPLE}${BOLD}>>> $1${NC}"
}

# 1. Tạo bản sao lưu an toàn cho ~/.config hiện tại
backup_current_config() {
    log_step "Bước 1: Sao lưu an toàn cấu hình hiện tại"
    log_info "Đang tạo bản sao lưu tại: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    for item in kdeglobals kwinrc plasmarc plasma-org.kde.plasma.desktop-appletsrc darklyrc kitty fcitx5 fontconfig; do
        if [ -e "$HOME/.config/$item" ]; then
            cp -r "$HOME/.config/$item" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    log_success "Đã sao lưu cấu hình cũ đề phòng sự cố."
}

# 2. Khôi phục Fonts & Fontconfig
restore_fonts() {
    log_step "Bước 2: Khôi phục Font chữ & Tinh chỉnh Fontconfig"
    mkdir -p "$HOME/.local/share/fonts"
    mkdir -p "$HOME/.config/fontconfig"

    log_info "Đang cài đặt font: SF Pro Display, JetBrains Mono, Annotation Mono, Iosevka Nerd Font..."
    cp -rf "$SCRIPT_DIR/local_share/fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null || true
    
    log_info "Đang áp dụng cấu hình fontconfig (Subpixel RGB, Hinting, LCD Filter)..."
    cp -rf "$SCRIPT_DIR/config/fontconfig/"* "$HOME/.config/fontconfig/" 2>/dev/null || true

    log_info "Đang cập nhật bộ nhớ đệm font chữ hệ thống (fc-cache)..."
    fc-cache -fv >/dev/null 2>&1 || true
    log_success "Đã khôi phục hoàn tất Font chữ và Fontconfig!"
}

# 3. Khôi phục Assets: Icons, Themes, Color Schemes, Aurorae, Plasmoids
restore_local_share() {
    log_step "Bước 3: Khôi phục Giao diện, Biểu tượng (Icons) & Widgets (Plasmoids)"
    
    mkdir -p "$HOME/.local/share/icons"
    mkdir -p "$HOME/.local/share/color-schemes"
    mkdir -p "$HOME/.local/share/aurorae/themes"
    mkdir -p "$HOME/.local/share/plasma"
    mkdir -p "$HOME/.local/share/easyeffects"

    log_info "Đang chép Cursor & Icon themes (Bibata-Modern-Ice, Papirus-Dark, candy-icons, Breeze-Noir)..."
    cp -rf "$SCRIPT_DIR/local_share/icons/"* "$HOME/.local/share/icons/" 2>/dev/null || true

    log_info "Đang chép Bảng màu (Catppuccin Mocha colors)..."
    cp -rf "$SCRIPT_DIR/local_share/color-schemes/"* "$HOME/.local/share/color-schemes/" 2>/dev/null || true

    log_info "Đang chép Chủ đề viền cửa sổ Aurorae (Otto)..."
    cp -rf "$SCRIPT_DIR/local_share/aurorae/"* "$HOME/.local/share/aurorae/" 2>/dev/null || true

    log_info "Đang chép Plasma Desktop Themes, Look-and-Feel & Plasmoids (KdeControlStation, modernclock, compactclock, Music.Waves)..."
    cp -rf "$SCRIPT_DIR/local_share/plasma/"* "$HOME/.local/share/plasma/" 2>/dev/null || true

    log_info "Đang chép Cấu hình EasyEffects Audio Equalizer..."
    cp -rf "$SCRIPT_DIR/local_share/easyeffects/"* "$HOME/.local/share/easyeffects/" 2>/dev/null || true

    log_success "Đã khôi phục thành công các tài nguyên giao diện!"
}

# 4. Khôi phục Hình nền & Icon nút bấm
restore_wallpapers() {
    log_step "Bước 4: Khôi phục Hình nền (Wallpapers) & Biểu tượng nút tùy chỉnh"
    mkdir -p "$HOME/Pictures/Wallpapers"
    mkdir -p "$HOME/Downloads"

    log_info "Đang chép hình nền vào ~/Pictures/Wallpapers/..."
    cp -rf "$SCRIPT_DIR/assets/wallpapers/"* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true

    # Đảm bảo đường dẫn hình nền cat-in-clouds.png và customButtonImage tồn tại đúng nơi plasma đang trỏ
    log_info "Đang liên kết hình nền mặc định để Plasma nhận diện ngay lập tức..."
    cp -f "$SCRIPT_DIR/assets/wallpapers/cat-in-clouds.png" "$HOME/Downloads/cat-in-clouds.png" 2>/dev/null || true
    
    if [ -f "$SCRIPT_DIR/assets/icons/control-centre.svg" ]; then
        cp -f "$SCRIPT_DIR/assets/icons/control-centre.svg" "$HOME/Downloads/control-centre-svgrepo-com (3).svg" 2>/dev/null || true
    fi

    log_success "Đã khôi phục hình nền desktop & icon thành công!"
}

# 5. Khôi phục Home dotfiles (.zshrc, .p10k.zsh, .gtkrc-2.0, avatar)
restore_home_files() {
    log_step "Bước 5: Khôi phục Shell Zsh, Terminal Kitty & GTK"
    
    log_info "Đang chép .zshrc, .p10k.zsh, .gtkrc-2.0, .gitconfig, .face..."
    cp -f "$SCRIPT_DIR/home/.zshrc" "$HOME/.zshrc" 2>/dev/null || true
    cp -f "$SCRIPT_DIR/home/.p10k.zsh" "$HOME/.p10k.zsh" 2>/dev/null || true
    cp -f "$SCRIPT_DIR/home/.gtkrc-2.0" "$HOME/.gtkrc-2.0" 2>/dev/null || true
    cp -f "$SCRIPT_DIR/home/.face" "$HOME/.face" 2>/dev/null || true
    cp -f "$SCRIPT_DIR/home/.face.icon" "$HOME/.face.icon" 2>/dev/null || true

    # Cấu hình Kitty Terminal
    mkdir -p "$HOME/.config/kitty"
    cp -rf "$SCRIPT_DIR/config/kitty/"* "$HOME/.config/kitty/" 2>/dev/null || true

    # Cấu hình Fastfetch
    mkdir -p "$HOME/.config/fastfetch"
    cp -rf "$SCRIPT_DIR/config/fastfetch/"* "$HOME/.config/fastfetch/" 2>/dev/null || true

    # Cấu hình Fcitx5 (Bộ gõ tiếng Việt)
    mkdir -p "$HOME/.config/fcitx5"
    cp -rf "$SCRIPT_DIR/config/fcitx5/"* "$HOME/.config/fcitx5/" 2>/dev/null || true

    # Cấu hình GTK 3 & GTK 4
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    cp -rf "$SCRIPT_DIR/config/gtk-3.0/"* "$HOME/.config/gtk-3.0/" 2>/dev/null || true
    cp -rf "$SCRIPT_DIR/config/gtk-4.0/"* "$HOME/.config/gtk-4.0/" 2>/dev/null || true

    # Bảng màu fetch terminal
    mkdir -p "$HOME/.config/hypr/scripts/quickshell"
    cp -rf "$SCRIPT_DIR/config/hypr/scripts/quickshell/"* "$HOME/.config/hypr/scripts/quickshell/" 2>/dev/null || true

    # Khôi phục các script tiện ích người dùng (~/.local/bin)
    mkdir -p "$HOME/.local/bin"
    if [ -d "$SCRIPT_DIR/local_bin" ]; then
        log_info "Đang khôi phục các script người dùng (sync-sweet-darkly)..."
        cp -rf "$SCRIPT_DIR/local_bin/"* "$HOME/.local/bin/" 2>/dev/null || true
        chmod +x "$HOME/.local/bin/"* 2>/dev/null || true
    fi

    log_success "Đã khôi phục hoàn tất Terminal, Zsh, Bộ gõ, Tiện ích và GTK!"
}

# 6. Khôi phục toàn bộ cấu hình KDE Plasma 6 (Bố cục panel, KWin, Darkly, Phím tắt)
restore_plasma_configs() {
    log_step "Bước 6: Khôi phục Bố cục KDE Plasma 6 & Hiệu ứng cửa sổ KWin"

    log_info "Tạm dừng plasmashell để ghi tệp cấu hình một cách an toàn..."
    systemctl --user stop plasma-plasmashell.service 2>/dev/null || kquitapp6 plasmashell 2>/dev/null || true
    sleep 1

    mkdir -p "$HOME/.config/kdedefaults"
    
    # Chép toàn bộ file cấu hình KDE
    for f in kdeglobals kwinrc kwinrulesrc kwinoutputconfig.json plasmarc plasmashellrc \
             darklyrc kcminputrc kscreenlockerrc ksplashrc kactivitymanagerdrc \
             kactivitymanagerd-statsrc kded5rc kglobalshortcutsrc dolphinrc spectaclerc \
             kiorc plasma-localerc plasma-nm plasmanotifyrc user-dirs.dirs knighttimerc; do
        if [ -f "$SCRIPT_DIR/config/$f" ]; then
            cp -f "$SCRIPT_DIR/config/$f" "$HOME/.config/"
        fi
    done

    # Chép kdedefaults
    cp -rf "$SCRIPT_DIR/config/kdedefaults/"* "$HOME/.config/kdedefaults/" 2>/dev/null || true

    # Xử lý tệp plasma-org.kde.plasma.desktop-appletsrc: Thay thế đường dẫn người dùng tự động nếu cần
    if [ -f "$SCRIPT_DIR/config/plasma-org.kde.plasma.desktop-appletsrc" ]; then
        log_info "Đang tinh chỉnh plasma-org.kde.plasma.desktop-appletsrc tương thích tài khoản $USER..."
        sed "s|/home/[^/]*|$HOME|g" "$SCRIPT_DIR/config/plasma-org.kde.plasma.desktop-appletsrc" > "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    fi

    # Áp dụng theme và con trỏ chuột bằng công cụ CLI của KDE
    log_info "Đang áp dụng Catppuccin_Final, CatppuccinMocha và Bibata-Modern-Ice..."
    plasma-apply-lookandfeel -a Catppuccin_Final 2>/dev/null || true
    plasma-apply-colorscheme CatppuccinMocha 2>/dev/null || plasma-apply-colorscheme Catppuccin 2>/dev/null || true
    plasma-apply-cursortheme Bibata-Modern-Ice 2>/dev/null || true

    # Khởi động lại plasmashell
    log_info "Đang khởi động lại giao diện Plasma Shell..."
    systemctl --user start plasma-plasmashell.service 2>/dev/null || kstart plasmashell >/dev/null 2>&1 &
    
    # Cập nhật KWin
    log_info "Đang nạp lại hiệu ứng trình quản lý cửa sổ KWin..."
    qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true

    log_success "Đã khôi phục hoàn chỉnh Giao diện và Bố cục KDE Plasma!"
}

# 7. Kiểm tra và Cài đặt Darkly Style & Window Decoration nếu chưa có
check_darkly_install() {
    log_step "Bước 7: Kiểm tra Darkly Window Decoration"
    if [ -f "/usr/lib/qt6/plugins/styles/darkly6.so" ] || [ -f "/usr/lib/qt6/plugins/org.kde.kdecoration3/org.kde.darkly.so" ]; then
        log_success "Darkly đã được cài đặt trên hệ thống!"
    else
        log_warn "Darkly chưa được cài đặt trong hệ thống. Đang tiến hành biên dịch từ mã nguồn..."
        if [ -d "$SCRIPT_DIR/packages/darkly" ]; then
            cd "$SCRIPT_DIR/packages/darkly"
            cmake -B build -S . -DBUILD_QT6=ON -DBUILD_QT5=OFF -DBUILD_TESTING=OFF
            cmake --build build -j "$(nproc)"
            sudo cmake --install build
            cd "$SCRIPT_DIR"
            log_success "Đã biên dịch và cài đặt Darkly thành công!"
        else
            log_warn "Không tìm thấy thư mục mã nguồn Darkly trong packages/darkly."
        fi
    fi
}

# 8. Áp dụng Tối ưu hóa hệ thống (/etc/)
apply_system_optimizations() {
    log_step "Bước 8: Áp dụng Tối ưu hóa Hệ thống (Pin, Hiệu năng, ZRAM, SSD)"
    
    echo -e "${YELLOW}Thao tác này yêu cầu quyền sudo để sao chép vào /etc:${NC}"
    echo "  1. setup-battery-saver.sh (Bộ tối ưu pin cực hạn ThinkPad: TLP, RAPL 10W, Powertop)"
    echo "  2. /etc/tlp.d/00-extreme-battery.conf (Giới hạn P-state 60%, xung GPU 650MHz, tắt Turbo Pin)"
    echo "  3. /etc/udev/rules.d/99-rapl-battery.rules (Khóa trần công suất Intel RAPL 10W khi dùng pin)"
    echo "  4. /etc/systemd/system/powertop.service (Powertop Auto-Tune toàn diện phần cứng)"
    echo "  5. /etc/modprobe.d/i915-powersave.conf (Tiết kiệm điện GPU Intel FBC & PSR)"
    echo "  6. /etc/environment (Độ nét font chữ Freetype stem-darkening)"
    echo "  7. /etc/systemd/zram-generator.conf (Tạo RAM ảo Swap nén siêu tốc ZRAM)"
    echo "  8. /etc/pacman.conf (Tải nhanh 5 luồng, giao diện màu sắc pacman)"
    echo "  9. Dịch vụ tlp.service, fstrim.timer và mask power-profiles-daemon"
    echo ""

    if [ "$1" = "--force" ]; then
        confirm="y"
    else
        read -p "Bạn có muốn áp dụng ngay các tối ưu hệ thống này không? (y/n): " confirm
    fi

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Chạy script tối ưu pin cực hạn nếu có
        if [ -f "$SCRIPT_DIR/system/setup-battery-saver.sh" ]; then
            log_info "Đang thực thi bộ script tối ưu pin setup-battery-saver.sh..."
            sudo bash "$SCRIPT_DIR/system/setup-battery-saver.sh"
        fi

        log_info "Đang áp dụng tinh chỉnh độ nét Font Freetype..."
        sudo cp -f "$SCRIPT_DIR/system/environment" /etc/environment

        log_info "Đang áp dụng cấu hình ZRAM..."
        sudo cp -f "$SCRIPT_DIR/system/zram-generator.conf" /etc/systemd/zram-generator.conf

        log_info "Đang áp dụng cấu hình Pacman..."
        sudo cp -f "$SCRIPT_DIR/system/pacman.conf" /etc/pacman.conf

        if [ -f "$SCRIPT_DIR/system/libinput/local-overrides.quirks" ]; then
            log_info "Đang áp dụng cấu hình phần cứng Touchpad Synaptics (/etc/libinput)..."
            sudo mkdir -p /etc/libinput
            sudo cp -f "$SCRIPT_DIR/system/libinput/local-overrides.quirks" /etc/libinput/
        fi

        log_info "Kích hoạt dịch vụ hệ thống và SSD Trim..."
        sudo systemctl enable --now fstrim.timer 2>/dev/null || true

        log_success "Đã áp dụng toàn bộ tối ưu hóa hệ thống thành công!"
    else
        log_info "Đã bỏ qua phần tối ưu hệ thống /etc."
    fi
}

# Hướng dẫn hoàn tất
finish_summary() {
    echo ""
    echo -e "${GREEN}${BOLD}======================================================================${NC}"
    echo -e "${GREEN}${BOLD}             KHÔI PHỤC TOÀN DIỆN HOÀN TẤT THÀNH CÔNG!                 ${NC}"
    echo -e "${GREEN}${BOLD}======================================================================${NC}"
    echo ""
    echo -e "Tất cả các thành phần đã được đưa trở về trạng thái tùy chỉnh chuẩn:"
    echo -e "  ${GREEN}✔${NC} Font chữ: SF Pro Display, JetBrains Mono, Iosevka Nerd Font"
    echo -e "  ${GREEN}✔${NC} Khử răng cưa font: Hinting hintslight + Subpixel RGB + LCD filter"
    echo -e "  ${GREEN}✔${NC} Giao diện: Catppuccin Mocha + Ant-Dark Plasma theme + Mauve accent"
    echo -e "  ${GREEN}✔${NC} Viền cửa sổ: Darkly trong suốt mờ ảo (Blur & Transparency)"
    echo -e "  ${GREEN}✔${NC} Con trỏ chuột & Biểu tượng: Bibata-Modern-Ice + Papirus-Dark"
    echo -e "  ${GREEN}✔${NC} Bố cục thanh Panel trên: KdeControlStation, Clock, Music.Waves, Taskbar"
    echo -e "  ${GREEN}✔${NC} Hiệu ứng KWin: Wobbly windows, Tiling 3 cột (0.25/0.5/0.25), Night Color"
    echo -e "  ${GREEN}✔${NC} Phím tắt: Meta+V clipboard, Meta+1..9 task manager, snapping phím tắt"
    echo -e "  ${GREEN}✔${NC} Terminal Kitty + Shell Zsh: Fastfetch banner động Catppuccin + P10k"
    echo -e "  ${GREEN}✔${NC} Bộ gõ tiếng Việt IBus Unikey"
    echo ""
    echo -e "${CYAN}${BOLD}[KHUYÊN DÙNG]${NC} Hãy ${BOLD}Đăng xuất (Log Out)${NC} hoặc ${BOLD}Khởi động lại (Reboot)${NC} để tất cả hiệu ứng và font chữ được kích hoạt đồng bộ 100% trên toàn bộ các ứng dụng."
    echo ""
}

# --- Main Flow ---
case "$1" in
    --all)
        print_banner
        backup_current_config
        restore_fonts
        restore_local_share
        restore_wallpapers
        restore_home_files
        restore_plasma_configs
        check_darkly_install
        apply_system_optimizations --force
        finish_summary
        ;;
    --ui)
        print_banner
        backup_current_config
        restore_fonts
        restore_local_share
        restore_wallpapers
        restore_home_files
        restore_plasma_configs
        finish_summary
        ;;
    --system)
        print_banner
        apply_system_optimizations
        ;;
    --fonts)
        print_banner
        restore_fonts
        ;;
    --help|-h)
        echo "Cách sử dụng: ./restore.sh [tùy chọn]"
        echo "  (không tham số) : Chạy trình hướng dẫn khôi phục đầy đủ (tương tác)"
        echo "  --all           : Khôi phục tất cả (UI, Fonts, Wallpapers, System)"
        echo "  --ui            : Chỉ khôi phục giao diện, bố cục, fonts và shell"
        echo "  --system        : Chỉ áp dụng tối ưu máy /etc (yêu cầu sudo)"
        echo "  --fonts         : Chỉ khôi phục font chữ và fontconfig"
        exit 0
        ;;
    *)
        print_banner
        echo "Trình hướng dẫn khôi phục sẽ tiến hành đưa toàn bộ hệ thống về giao diện"
        echo "và thiết lập tùy chỉnh tối ưu ban đầu của bạn."
        echo ""
        read -p "Nhấn [Enter] để bắt đầu quá trình khôi phục..."
        backup_current_config
        restore_fonts
        restore_local_share
        restore_wallpapers
        restore_home_files
        restore_plasma_configs
        check_darkly_install
        apply_system_optimizations
        finish_summary
        ;;
esac
