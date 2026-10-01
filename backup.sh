#!/usr/bin/env bash
# ==============================================================================
# Script Tự Động Sao Lưu / Cập Nhật Toàn Bộ Tùy Biến Vào Project Này
# Tác giả: nguyendinhkhanh
# Mô tả: Khi bạn có bất kỳ thay đổi nào mới (thêm widget, đổi phím tắt, đổi font,
#        tinh chỉnh KWin, cài phần mềm mới...), chạy script này để đồng bộ lại.
# ==============================================================================

set -e

# Màu sắc hiển thị
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${PURPLE}${BOLD}"
echo "======================================================================"
echo "    ARCH LINUX & KDE PLASMA 6 - BACKUP / SYNC PROJECT WIZARD          "
echo "======================================================================"
echo -e "${NC}"
echo -e "${CYAN}Đang đồng bộ từ hệ thống vào:${NC} $SCRIPT_DIR"

log_info() {
    echo -e "${BLUE}[ĐỒNG BỘ]${NC} $1"
}

# 1. Cấu hình ~/.config
log_info "Sao lưu tệp cấu hình KDE Plasma 6 & KWin..."
for f in kdeglobals kwinrc kwinrulesrc kwinoutputconfig.json plasmarc plasmashellrc \
         darklyrc kcminputrc kscreenlockerrc ksplashrc kactivitymanagerdrc \
         kactivitymanagerd-statsrc kded5rc kglobalshortcutsrc dolphinrc spectaclerc \
         kiorc plasma-localerc plasma-nm plasmanotifyrc user-dirs.dirs plasma-org.kde.plasma.desktop-appletsrc; do
    if [ -f "$HOME/.config/$f" ]; then
        cp -f "$HOME/.config/$f" "$SCRIPT_DIR/config/"
    fi
done

cp -rf "$HOME/.config/kdedefaults/"* "$SCRIPT_DIR/config/kdedefaults/" 2>/dev/null || true
cp -rf "$HOME/.config/fontconfig/"* "$SCRIPT_DIR/config/fontconfig/" 2>/dev/null || true
cp -rf "$HOME/.config/kitty/"* "$SCRIPT_DIR/config/kitty/" 2>/dev/null || true
cp -rf "$HOME/.config/fastfetch/"* "$SCRIPT_DIR/config/fastfetch/" 2>/dev/null || true
cp -rf "$HOME/.config/fcitx5/"* "$SCRIPT_DIR/config/fcitx5/" 2>/dev/null || true
cp -rf "$HOME/.config/easyeffects/"* "$SCRIPT_DIR/config/easyeffects/" 2>/dev/null || true
if [ -f "$HOME/.config/hypr/scripts/quickshell/qs_colors.json" ]; then
    cp -f "$HOME/.config/hypr/scripts/quickshell/qs_colors.json" "$SCRIPT_DIR/config/hypr/scripts/quickshell/"
fi

# 2. Cấu hình Home
log_info "Sao lưu dotfiles shell zsh, terminal, p10k, avatar..."
cp -f "$HOME/.zshrc" "$SCRIPT_DIR/home/" 2>/dev/null || true
cp -f "$HOME/.p10k.zsh" "$SCRIPT_DIR/home/" 2>/dev/null || true
cp -f "$HOME/.gtkrc-2.0" "$SCRIPT_DIR/home/" 2>/dev/null || true
cp -f "$HOME/.gitconfig" "$SCRIPT_DIR/home/" 2>/dev/null || true
cp -f "$HOME/.face" "$SCRIPT_DIR/home/" 2>/dev/null || true
cp -f "$HOME/.face.icon" "$SCRIPT_DIR/home/" 2>/dev/null || true

# 3. Cấu hình Local Share (Themes, Plasmoids, Color-schemes)
log_info "Sao lưu tài nguyên ~/.local/share (color-schemes, aurorae, plasma plasmoids)..."
cp -rf "$HOME/.local/share/color-schemes/"* "$SCRIPT_DIR/local_share/color-schemes/" 2>/dev/null || true
cp -rf "$HOME/.local/share/aurorae/"* "$SCRIPT_DIR/local_share/aurorae/" 2>/dev/null || true
cp -rf "$HOME/.local/share/plasma/"* "$SCRIPT_DIR/local_share/plasma/" 2>/dev/null || true
cp -rf "$HOME/.local/share/easyeffects/"* "$SCRIPT_DIR/local_share/easyeffects/" 2>/dev/null || true

# 4. Sao lưu danh sách phần mềm (Packages)
log_info "Cập nhật danh sách phần mềm Arch & AUR..."
pacman -Qqe > "$SCRIPT_DIR/packages/pkglist-repo.txt" 2>/dev/null || true
pacman -Qqem > "$SCRIPT_DIR/packages/pkglist-aur.txt" 2>/dev/null || true

# 5. Sao lưu tối ưu hệ thống /etc/
log_info "Kiểm tra và cập nhật cấu hình tối ưu hệ thống..."
if [ -f "/etc/tlp.d/00-extreme-battery.conf" ]; then
    cp -f /etc/tlp.d/00-extreme-battery.conf "$SCRIPT_DIR/system/tlp.d/"
fi
if [ -f "/etc/modprobe.d/i915-powersave.conf" ]; then
    cp -f /etc/modprobe.d/i915-powersave.conf "$SCRIPT_DIR/system/modprobe.d/"
fi
if [ -f "/etc/environment" ]; then
    cp -f /etc/environment "$SCRIPT_DIR/system/environment"
fi
if [ -f "/etc/systemd/zram-generator.conf" ]; then
    cp -f /etc/systemd/zram-generator.conf "$SCRIPT_DIR/system/zram-generator.conf"
fi
if [ -f "/etc/pacman.conf" ]; then
    cp -f /etc/pacman.conf "$SCRIPT_DIR/system/pacman.conf"
fi
if [ -f "/etc/udev/rules.d/99-rapl-battery.rules" ]; then
    mkdir -p "$SCRIPT_DIR/system/udev.rules.d"
    cp -f /etc/udev/rules.d/99-rapl-battery.rules "$SCRIPT_DIR/system/udev.rules.d/"
fi
if [ -f "/etc/systemd/system/powertop.service" ]; then
    mkdir -p "$SCRIPT_DIR/system/services"
    cp -f /etc/systemd/system/powertop.service "$SCRIPT_DIR/system/services/"
fi

echo ""
echo -e "${GREEN}${BOLD}ĐÃ ĐỒNG BỘ TOÀN BỘ CẤU HÌNH MỚI NHẤT VÀO PROJECT THÀNH CÔNG!${NC}"
echo -e "Thời gian cập nhật: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
