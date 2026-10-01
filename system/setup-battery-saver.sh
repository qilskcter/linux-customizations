#!/usr/bin/env bash
set -e

# ==========================================================
# SCRIPT TỐI ƯU PIN CỰC HẠN (EXTREME BATTERY) CHO THINKPAD E490
# ==========================================================

if [ "$EUID" -ne 0 ]; then
  echo "[-] Vui lòng chạy script với quyền root: sudo bash $0"
  exit 1
fi

echo "[+] 1. Đảm bảo các công cụ TLP và Powertop đã sẵn sàng..."
pacman -S --needed --noconfirm tlp tlp-rdw powertop

echo "[+] 2. Tắt và mask power-profiles-daemon để TLP toàn quyền tối ưu..."
systemctl stop power-profiles-daemon.service || true
systemctl mask power-profiles-daemon.service

echo "[+] 3. Cấu hình TLP nâng cao mức cực hạn (/etc/tlp.d/00-extreme-battery.conf)..."
mkdir -p /etc/tlp.d
cat << 'EOF' > /etc/tlp.d/00-extreme-battery.conf
# ==========================================
# CẤU HÌNH TIẾT KIỆM PIN CỰC ĐẠI CHO THINKPAD
# ==========================================
TLP_ENABLE=1

# 1. CPU Scaling & EPP
CPU_SCALING_GOVERNOR_ON_AC=powersave
CPU_SCALING_GOVERNOR_ON_BAT=powersave

CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=power

# Tắt Turbo Boost khi dùng Pin (tiết kiệm 40-50% điện CPU)
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0

# Khóa trần hiệu năng CPU P-state ở mức 60% trên Pin (giữ điện áp CPU thấp)
CPU_MIN_PERF_ON_BAT=0
CPU_MAX_PERF_ON_BAT=60

CPU_HWP_DYN_BOOST_ON_AC=1
CPU_HWP_DYN_BOOST_ON_BAT=0

# 2. Intel UHD Graphics 620
INTEL_GPU_MIN_FREQ_ON_BAT=300
INTEL_GPU_MAX_FREQ_ON_BAT=650
INTEL_GPU_BOOST_FREQ_ON_BAT=750

# 3. PCIe Bus & SATA SSD
PCIE_ASPM_ON_AC=default
PCIE_ASPM_ON_BAT=powersupersave

SATA_LINKPWR_ON_AC=med_power_with_dipm
SATA_LINKPWR_ON_BAT=med_power_with_dipm

# 4. Âm thanh an toàn cho Conexant CX11880
SOUND_POWER_SAVE_ON_AC=0
SOUND_POWER_SAVE_ON_BAT=1
SOUND_POWER_SAVE_CONTROLLER=N

# 5. Tắt Wake-on-LAN cho card mạng có dây Realtek
WOL_DISABLE=Y

# 6. Wi-Fi Power Save
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# 7. USB Autosuspend
USB_AUTOSUSPEND=1
USB_EXCLUDE_AUDIO=1

# Tự động tắt Bluetooth khi khởi động dùng pin
DEVICES_TO_DISABLE_ON_BAT_START="bluetooth"
EOF

echo "[+] 4. Cấu hình i915 Graphics Powersave (/etc/modprobe.d/i915-powersave.conf)..."
cat << 'EOF' > /etc/modprobe.d/i915-powersave.conf
options i915 enable_fbc=1 enable_psr=1
EOF

echo "[+] 5. Tạo udev rule giới hạn công suất gói CPU (Intel RAPL limit 10W trên pin)..."
cat << 'EOF' > /etc/udev/rules.d/99-rapl-battery.rules
# Khi rút sạc (online=0): Giới hạn trần công suất CPU ở 10W (10000000 uW)
SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/usr/bin/bash -c 'if [ -f /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw ]; then echo 10000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw; fi'"

# Khi cắm sạc (online=1): Mở lại công suất tối đa 25W (25000000 uW)
SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/usr/bin/bash -c 'if [ -f /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw ]; then echo 25000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw; fi'"
EOF
udevadm control --reload-rules || true

echo "[+] 6. Tạo systemd service cho Powertop Auto-Tune..."
cat << 'EOF' > /etc/systemd/system/powertop.service
[Unit]
Description=Powertop Tunings
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now powertop.service

echo "[+] 7. Tối ưu ALSA cho chip âm thanh..."
amixer -c 0 set 'Auto-Mute Mode' 'Enabled' 2>/dev/null || true
amixer -c 0 set Master unmute 2>/dev/null || true
amixer -c 0 set Headphone unmute 100% 2>/dev/null || true
alsactl store 2>/dev/null || true

echo "[+] 8. Khởi động lại dịch vụ TLP..."
systemctl enable tlp.service
systemctl restart tlp.service
tlp start

# Áp dụng ngay giới hạn 10W nếu hiện đang chạy pin
if [ "$(cat /sys/class/power_supply/AC*/online 2>/dev/null || cat /sys/class/power_supply/ADP*/online 2>/dev/null)" = "0" ]; then
  if [ -f /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw ]; then
    echo 10000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw
  fi
fi

echo "=========================================================="
echo " [OK] ĐÃ CẤU HÌNH XONG TỐI ƯU PIN CỰC HẠN!"
echo " - Giới hạn trần công suất CPU (RAPL) 10W khi dùng pin."
echo " - Giới hạn xung GPU 650MHz & trần CPU P-state 60%."
echo " - Bật Powertop Auto-tune toàn diện phần cứng."
echo " - Tắt Wake-on-LAN card Ethernet."
echo "=========================================================="
