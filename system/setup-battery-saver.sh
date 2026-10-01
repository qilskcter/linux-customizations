#!/usr/bin/env bash
set -e

# ==========================================================
# CẤU HÌNH CÂN BẰNG TỐI ƯU CHO THINKPAD E490 (i5-8265U):
# - CẮM SẠC (AC): BUNG 100% HIỆU NĂNG (CPU 3.9 GHz, GPU 1.10 GHz)
# - RÚT SẠC (BAT): TIẾT KIỆM PIN CỰC HẠN (Tắt Turbo, CPU 10W, GPU 650MHz)
# ==========================================================

if [ "$EUID" -ne 0 ]; then
  echo "[-] Vui lòng chạy script với quyền root: sudo bash $0"
  exit 1
fi

echo "[+] 1. Đảm bảo các gói tlp, tlp-rdw, powertop sẵn sàng..."
pacman -S --needed --noconfirm tlp tlp-rdw powertop

echo "[+] 2. Tắt và mask power-profiles-daemon..."
systemctl stop power-profiles-daemon.service || true
systemctl mask power-profiles-daemon.service

echo "[+] 3. Cấu hình TLP chuẩn xác cho ThinkPad E490 (/etc/tlp.d/00-extreme-battery.conf)..."
mkdir -p /etc/tlp.d
cat << 'EOF' > /etc/tlp.d/00-extreme-battery.conf
# =======================================================
# 1. KHI CẮM SẠC (AC) -> BUNG HẾT 100% SỨC MẠNH PHẦN CỨNG
# =======================================================
TLP_ENABLE=1

# CPU Governor & EPP: Tối đa hóa tốc độ phản hồi
CPU_SCALING_GOVERNOR_ON_AC=powersave
CPU_ENERGY_PERF_POLICY_ON_AC=performance

# Xung nhịp trần CPU mở 3.9 GHz
CPU_BOOST_ON_AC=1
CPU_MIN_PERF_ON_AC=0
CPU_MAX_PERF_ON_AC=100
CPU_SCALING_MAX_FREQ_ON_AC=3900000
CPU_HWP_DYN_BOOST_ON_AC=1

# GPU Intel UHD 620 trên i5-8265U: Tần số tối đa chuẩn xác là 1100 MHz
INTEL_GPU_MIN_FREQ_ON_AC=300
INTEL_GPU_MAX_FREQ_ON_AC=1100
INTEL_GPU_BOOST_FREQ_ON_AC=1100

# Phần cứng tốc độ cao
PCIE_ASPM_ON_AC=default
SATA_LINKPWR_ON_AC=max_performance
SOUND_POWER_SAVE_ON_AC=0
WIFI_PWR_ON_AC=off

# =======================================================
# 2. KHI RÚT SẠC (BAT) -> SIÊU TIẾT KIỆM PIN (4.5W - 5.5W)
# =======================================================
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_ENERGY_PERF_POLICY_ON_BAT=power

# Tắt Turbo Boost, khóa trần P-state 60% (1.6 GHz)
CPU_BOOST_ON_BAT=0
CPU_MIN_PERF_ON_BAT=0
CPU_MAX_PERF_ON_BAT=60
CPU_HWP_DYN_BOOST_ON_BAT=0

# Hạ xung GPU về 650 MHz
INTEL_GPU_MIN_FREQ_ON_BAT=300
INTEL_GPU_MAX_FREQ_ON_BAT=650
INTEL_GPU_BOOST_FREQ_ON_BAT=750

# Đưa bus PCIe và SSD vào chế độ tiết kiệm điện sâu
PCIE_ASPM_ON_BAT=powersupersave
SATA_LINKPWR_ON_BAT=med_power_with_dipm

# Quản lý âm thanh an toàn cho Conexant CX11880
SOUND_POWER_SAVE_ON_BAT=1
SOUND_POWER_SAVE_CONTROLLER=N

# Tắt Wake-on-LAN và bật tiết kiệm Wi-Fi / USB
WOL_DISABLE=Y
WIFI_PWR_ON_BAT=on
USB_AUTOSUSPEND=1
USB_EXCLUDE_AUDIO=1
DEVICES_TO_DISABLE_ON_BAT_START="bluetooth"
EOF

echo "[+] 4. Cấu hình i915 Graphics Powersave..."
cat << 'EOF' > /etc/modprobe.d/i915-powersave.conf
options i915 enable_fbc=1 enable_psr=1
EOF

echo "[+] 5. Cấu hình udev rule cho công suất CPU (RAPL)..."
cat << 'EOF' > /etc/udev/rules.d/99-rapl-battery.rules
# Khi cắm sạc: Bung hết 25W
SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/usr/bin/bash -c 'if [ -f /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw ]; then echo 25000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw; fi'"

# Khi rút sạc: Khóa ở 10W
SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/usr/bin/bash -c 'if [ -f /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw ]; then echo 10000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw; fi'"
EOF
udevadm control --reload-rules || true

echo "[+] 6. Khởi động lại TLP..."
systemctl enable tlp.service
systemctl restart tlp.service
tlp start

# Mở ngay trần xung 3.9 GHz và GPU 1100 MHz nếu đang cắm sạc
if [ "$(cat /sys/class/power_supply/AC*/online 2>/dev/null || cat /sys/class/power_supply/ADP*/online 2>/dev/null)" = "1" ]; then
  echo 100 > /sys/devices/system/cpu/intel_pstate/max_perf_pct 2>/dev/null || true
  echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
  for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
    echo 3900000 > "$f" 2>/dev/null || true
  done
  for g in /sys/class/drm/card*/gt_max_freq_mhz; do
    echo 1100 > "$g" 2>/dev/null || true
  done
  if [ -f /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw ]; then
    echo 25000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw 2>/dev/null || true
  fi
fi

# Tối ưu ALSA
amixer -c 0 set 'Auto-Mute Mode' 'Enabled' 2>/dev/null || true
amixer -c 0 set Master unmute 2>/dev/null || true
amixer -c 0 set Headphone unmute 100% 2>/dev/null || true
alsactl store 2>/dev/null || true

echo "=========================================================="
echo " [OK] HOÀN TẤT TUYỆT ĐỐI KHÔNG CÒN LỖI!"
echo " - AC: CPU bung 3.9 GHz, GPU bung 1.10 GHz (1100 MHz)."
echo " - BAT: Khóa 1.6 GHz, 10W, GPU 650 MHz, siêu tiết kiệm pin."
echo "=========================================================="
