# System Requirements for Fedora 41 to 43 Upgrade

## Document Information

- **Version:** 1.0.0
- **Last Updated:** January 18, 2026
- **Applies To:** Fedora 41 Workstation → Fedora 43 Workstation
- **Status:** Current and Verified

---

## 🖥️ Hardware Requirements

### Minimum Hardware Specifications

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Processor** | 2 GHz dual-core | 2.5+ GHz quad-core |
| **RAM** | 2 GB | 8 GB or more |
| **Storage** | 5 GB free on `/` | 15+ GB free on `/` |
| **Disk Type** | HDD or SSD | SSD (faster upgrade) |
| **Display** | 1024x768 | 1920x1080 or higher |
| **Power** | Standard PSU | UPS recommended |

### Supported Architectures

✅ **Primary Support:**
- x86_64 (Intel/AMD 64-bit) - Fully supported

✅ **Secondary Support:**
- aarch64 (ARM 64-bit) - Procedures similar but not explicitly documented
- ppc64le (IBM Power) - Specialized deployment only

❌ **Not Supported:**
- 32-bit x86 (i686)
- ARM 32-bit
- RISC-V

### Storage Considerations

#### Disk Space Requirements

**During Upgrade:**
```
Root Partition (/):
  ├─ Fedora 41 system:        ~3-4 GB
  ├─ Downloaded packages:     ~2-3 GB
  ├─ Upgrade staging:         ~1-2 GB
  └─ Buffer/Safety margin:    ~1 GB
  ├─ TOTAL REQUIRED:          ~7-10 GB free
  └─ RECOMMENDED:             ~15+ GB free
```

**After Cleanup:**
- Post-upgrade cleanup recovers: 2-5 GB
- Final free space: 10-20+ GB (depending on initial state)

#### Disk Space Verification

```bash
# Check current disk usage
df -h /

# Example output:
# Filesystem     Size  Used Avail Use% Mounted on
# /dev/mapper/fedora-root  50G   30G   20G  60% /
#                 ↑ 20G available = GOOD (meets 5GB minimum + buffer)

# Check specific directory sizes
du -sh /var/cache/dnf
du -sh /var/log
du -sh /home
```

**Minimum Required:** 5 GB free on root partition
**Safety Buffer:** 10+ GB free recommended
**Optimal:** 15+ GB free for comfortable upgrade

### Network Requirements

#### Connectivity
- **Type:** Broadband internet connection recommended
- **Speed:** 10+ Mbps minimum for reasonable download times
- **Stability:** Stable, non-metered connection preferred
- **Duration:** Connection needed for 30-60 minutes during upgrade

#### Network Considerations
- WiFi: Generally acceptable, but wired preferred for stability
- Mobile hotspot: Works but may have data caps
- Metered connections: Fedora 43 download ~2-3 GB

#### Data Transfer Estimates

```
Fedora 43 Download Package Sizes:

Minimal system upgrade:     ~1-2 GB
Standard Workstation:       ~2-3 GB
With development tools:     ~3-5 GB
With large applications:    ~5-7 GB

Approximate download times (typical broadband):
  100 Mbps connection:      3-5 minutes
  50 Mbps connection:       6-10 minutes
  20 Mbps connection:       15-25 minutes
  10 Mbps connection:       30-50 minutes
```

---

## 🔋 Power & Stability

### Power Supply Requirements

#### Minimum Specifications
- PSU Output: 300W minimum (standard workstation)
- Stability: Stable voltage output without fluctuations
- Battery Backup: UPS or surge protector recommended

#### Recommended Configuration

```
Uninterruptible Power Supply (UPS)

Why UPS is important:
  ✓ Upgrade process takes 30-60 minutes
  ✓ Power failure during upgrade can corrupt system
  ✓ Recovery from corruption is complex/time-consuming
  ✓ Backup and restore takes 1-2 hours minimum

UPS Recommendations:
  • Capacity: 500VA / 300W minimum
  • Backup Time: 30+ minutes (covers entire upgrade)
  • Examples: APC Back-UPS 600VA, Cyberpower, Belkin
```

#### Thermal Considerations

```
System Temperature Monitoring:

During upgrade, system will have moderate CPU load:
  • CPU: 40-70% utilization
  • Temperature: May reach 60-80°C on air cooling
  • Duration: 20-45 minutes sustained load

Recommendations:
  ✓ Ensure adequate case ventilation
  ✓ Clean heatsinks/fans before upgrade
  ✓ Disable power saving modes (keeps CPU cool)
  ✓ Monitor temperatures: watch sensors
```

---

## 💾 Disk & Filesystem Requirements

### Filesystem Support

#### Supported Filesystems
- ✅ **ext4** - Primary/default (fully supported)
- ✅ **Btrfs** - Modern (Timeshift snapshots native)
- ✅ **XFS** - Enterprise (supported)
- ✅ **F2FS** - SSD optimized (supported)
- ⚠️ **LUKS** - Encrypted (requires header backup)

#### LVM (Logical Volume Manager)
- ✅ Supported for root and boot volumes
- ✅ No special requirements or limitations
- ⚠️ Ensure adequate space in volume group

#### LUKS Encryption Handling

```
If using LUKS encryption:

1. Backup LUKS headers (CRITICAL):
   sudo cryptsetup luksHeaderBackup /dev/sdXY \
     --header-backup-file ~/luks-backup

2. Verify headers backed up correctly

3. Proceed with normal upgrade

4. After successful upgrade, clean up backups
```

### Partitioning Scheme

#### Minimum Partition Layout

```
Standard two-partition setup:

/dev/sdaX or /boot (if separate):  1-2 GB
/dev/sdaY or /     (root):         15+ GB free
```

#### Recommended Partition Layout

```
Three-partition setup (recommended):

/dev/sda1 → /boot           2 GB
/dev/sda2 → /               30+ GB
/dev/sda3 → /home           remaining space
```

#### Backup Partition Setup

```
Four-partition setup (backup-aware):

/dev/sda1 → /boot           2 GB
/dev/sda2 → /               30 GB
/dev/sda3 → /home           50+ GB
/dev/sda4 → /mnt/backup     20+ GB (backup destination)
```

---

## 🔒 Security & Access Requirements

### User Access Requirements

#### Root/Sudo Access
- **Required:** YES - All upgrade operations need root privileges
- **Method:** Using `sudo` command
- **Verification:** Run `sudo id` (should show uid=0)

#### Sudo Configuration

```bash
# Verify sudo access
sudo -l

# Output should show:
# User <username> may run the following commands:
#     (ALL) ALL
```

### SELinux & Security Modules

#### SELinux Status

```bash
# Check SELinux status
getenforce
# Output: Enforcing, Permissive, or Disabled

# For upgrade: Enforcing mode is fine (standard)
# Disabled mode: Also acceptable
# Permissive mode: Works but not recommended for security
```

#### Firewall Status

```bash
# Check firewall
sudo systemctl is-active firewalld
# Output: active

# During upgrade, firewall can remain enabled
# (affects package download speed minimally)
```

---

## 📦 Software Requirements

### Current Fedora Version

```bash
# Verify you're on Fedora 41
cat /etc/os-release | grep VERSION_ID
# Should output: VERSION_ID=41
```

### Required Software

#### DNF Package Manager
- **Required Version:** DNF5 (default in Fedora 41)
- **Verify:** `dnf --version` (should show 5.x.x)
- **Status:** No installation needed (pre-installed on F41)

#### Essential Utilities

```bash
# Verify availability (should all exist)
which dnf           # Package manager
which grubby        # GRUB configuration
which tar           # Archive utility
which rsync         # Sync/backup utility
which journalctl    # System logs
```

#### Optional But Recommended

```bash
# For backup procedures
sudo dnf install timeshift

# For system information
sudo dnf install neofetch fastfetch screenfetch

# For post-upgrade tasks
sudo dnf install rpmconf

# For ASCII logo display
sudo dnf install figlet lolcat
```

---

## 🌐 Fedora Mirror Requirements

### Mirror Availability

```bash
# Fedora uses global mirror network
# Automatic selection based on geographic location

# Verify mirror access
curl -I https://mirrors.fedoraproject.org/
# Should return HTTP 200 OK
```

### Mirror Configuration

#### Default Mirror (Usually Works)
```bash
# DNF automatically selects closest mirror
# No configuration needed
```

#### Manual Mirror Selection (If Needed)
```bash
# Check available mirrors
dnf repolist enabled

# If slow, configure specific mirror
# Edit /etc/dnf/dnf.conf
# Add: fastestmirror=true (DNF finds fastest)
```

---

## 📋 Pre-Upgrade Checklist

### System Status Verification

```bash
# 1. Check current Fedora version
cat /etc/os-release | grep "VERSION_ID"
# Result: VERSION_ID=41 ✓

# 2. Verify kernel is up to date
sudo dnf upgrade --refresh
sudo reboot  # If kernel updated

# 3. Check disk space
df -h /
# Result: 5GB+ free ✓

# 4. Verify network connectivity
ping -c 1 mirrors.fedoraproject.org
# Result: Connected ✓

# 5. Check for failed services
systemctl list-units --failed
# Result: 0 failed services ✓

# 6. Verify DNF availability
dnf --version
# Result: DNF 5.x.x ✓
```

### Backup Prerequisite Checklist

```bash
# Before starting ANY backup procedure:

# 1. Sufficient disk space for backup destination
df -h /mnt/backup
# Need: Total system size + 10% (e.g., 50GB system = 55GB required)

# 2. Backup destination accessible
mount | grep backup
# Result: /mnt/backup mounted ✓

# 3. Write permissions on backup destination
touch /mnt/backup/test-file
rm /mnt/backup/test-file
# Result: Can write ✓

# 4. Adequate free space in backup destination
df -h /mnt/backup
# Need: 10GB+ free space
```

---

## 🔍 Known Compatibility Issues

### Hardware-Specific Issues

#### NVIDIA Graphics

```bash
# If using NVIDIA GPU:
lspci | grep -i nvidia

# NVIDIA driver may require update after upgrade
# Use: NVIDIA driver manager or 
#      RPM Fusion proprietary drivers
```

#### Intel Integrated Graphics

```bash
# Usually no issues, but verify:
lspci | grep -i intel
lspci | grep -i vga

# Check IOMMU if needed for passthrough
cat /proc/cmdline | grep iommu
```

#### AMD/ATI Graphics

```bash
# Check for AMD GPU
lspci | grep -i amd

# AMDGPU driver (open-source) should work fine
# AMDGPU-PRO (closed-source) may need update
```

### Network Adapter Issues

```bash
# Check network devices
nmcli device status

# Most common NICs should work post-upgrade
# If WiFi issues: Update NetworkManager
sudo dnf reinstall NetworkManager
```

### Storage Controller Issues

```bash
# Check SATA/NVMe controllers
lspci | grep -E "SATA|NVMe"

# Most controllers are kernel-supported
# Rare proprietary controllers may need drivers
```

---

## 🔧 Software Compatibility

### Kernel Modules

```bash
# Custom kernel modules may need rebuilding post-upgrade
# Examples: VirtualBox, NVIDIA drivers, ZFS

# Check loaded modules:
lsmod | head -20

# After upgrade, reinstall if needed:
sudo dnf reinstall virtualbox-guest-kernel-modules
```

### Third-Party Repositories

```bash
# Check enabled repositories
dnf repolist

# Common third-party repos:
# - RPM Fusion (multimedia codecs)
# - Microsoft repo (VSCode)
# - Google repo (Chrome)
# - NodeSource (Node.js)

# These usually update automatically during F43 upgrade
```

### Flatpak & Snap

```bash
# Flatpak usually unaffected
flatpak list --app

# Snap (if installed)
snap list

# Both continue working post-upgrade
```

---

## 📊 Performance Expectations

### Upgrade Duration

```
Typical upgrade timeline on modern hardware (SSD, 8GB RAM):

Phase 1: Package Download         10-15 minutes (depends on ISP)
Phase 2: Reboot to upgrade mode   1-2 minutes
Phase 3: Package installation     15-30 minutes
Phase 4: Post-upgrade reboot      2-5 minutes
Phase 5: System initialization    3-5 minutes
Phase 6: Post-upgrade tasks       15-30 minutes
─────────────────────────────────────────────────
Total Time (minimum):             45 minutes
Total Time (comfortable):         1.5-2 hours
```

### Performance During Upgrade

```
System behavior during upgrade process:

CPU Usage:     40-70% (elevated but not maxed)
Disk I/O:      Heavy (sustained writes)
Memory Usage:  ~500MB-1GB (minimal for Fedora)
Network:       Active during download phase
Responsiveness: Degraded during installation phase
```

---

## ✅ Final Verification Checklist

### Pre-Upgrade (Must Complete All)

- [ ] Running Fedora 41 (verify: `cat /etc/os-release`)
- [ ] 5GB+ free disk space on root partition (`df -h /`)
- [ ] Stable internet connection (ping fedoraproject.org)
- [ ] Sudo/root access available (`sudo id`)
- [ ] System fully updated (`sudo dnf upgrade --refresh`)
- [ ] Backups created (Timeshift or Tar or Rsync)
- [ ] Backup integrity verified
- [ ] No failed services (`systemctl list-units --failed`)
- [ ] Power supply adequate (UPS recommended)
- [ ] DNF available and working (`dnf --version`)

### During Upgrade (Don't Interrupt)

- [ ] Power remains stable (no power loss)
- [ ] System not forcefully interrupted
- [ ] Monitor connections remain active
- [ ] Package installation progresses
- [ ] System reboots automatically

### Post-Upgrade (Must Complete All)

- [ ] System boots successfully
- [ ] Fedora 43 verified (`cat /etc/os-release`)
- [ ] Kernel updated to 6.17.x (`uname -r`)
- [ ] No failed services (`systemctl list-units --failed`)
- [ ] Network connectivity works
- [ ] Package manager functional (`dnf list installed | wc -l`)
- [ ] All documentation procedures completed (Part 3)
- [ ] Post-upgrade backup created (Timeshift snapshot)

---

## 🆘 Unable to Meet Requirements?

### If Insufficient Disk Space

```bash
# Before upgrade, free up space:

# Clean cache
sudo dnf clean all

# Archive old logs
sudo journalctl --vacuum-size=50M

# Remove old kernels
sudo dnf remove $(dnf repoquery --installonly --latest-limit=-3 -q)

# Remove unused packages
sudo dnf autoremove

# Empty temp directories (safely)
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
```

**After cleanup, recheck:** `df -h /`

### If No UPS Available

```bash
# Minimize power-loss risk:

# 1. Ensure stable power outlet (not shared with heavy loads)
# 2. Keep system plugged in throughout upgrade (laptops: AC power)
# 3. Disable sleep/suspend during upgrade
# 4. Keep system well-ventilated
# 5. Monitor system temperature: watch sensors

# Disable power saving:
sudo systemctl mask sleep.target suspend.target hibernate.target
```

### If Network Connection Unstable

```bash
# Use download-only mode, install later:

# Step 1: Download packages (can retry if interrupted)
sudo dnf system-upgrade download --releasever=43 -d

# Step 2: When ready with stable connection, install:
sudo dnf system-upgrade reboot
```

### If No Backup Storage Available

```bash
# Use minimum backup strategy:

# 1. Export package list
rpm -qa > ~/f41-packages.txt

# 2. Create bootable recovery USB
dd if=Fedora-Workstation-Live-43-1.3-x86_64-ISO \
   of=/dev/sdX bs=4M status=progress

# 3. After successful upgrade, create post-upgrade backup
sudo timeshift --create --comments "F43 stable"
```

---

## 📞 System-Specific Notes

### Desktop Environments

#### GNOME (Default in Fedora Workstation)
- **Status:** Fully supported
- **Version:** GNOME 49 in Fedora 43
- **Notes:** Wayland-only (no X11 support)
- **Post-upgrade:** Usually works seamlessly

#### KDE Plasma (Fedora KDE Spin)
- **Status:** Supported but not documented here
- **Procedures:** Similar but graphical settings differ
- **Post-upgrade:** Usually works seamlessly

#### XFCE (Fedora XFCE Spin)
- **Status:** Supported but not documented here
- **Procedures:** Similar with minor differences
- **Post-upgrade:** Usually works seamlessly

### Boot Systems

#### UEFI Boot
- ✅ Fully supported
- ⚠️ GRUB reinstall NOT needed (automatic)
- ✅ Secure Boot compatible

#### BIOS (Legacy) Boot
- ✅ Fully supported
- ⚠️ GRUB may need reinstall (documented in Part 3.4)
- ✅ No Secure Boot involved

---

## 🎯 Summary

### Quick Requirements Check

| Requirement | Status | Action if Missing |
|-------------|--------|-------------------|
| Fedora 41 | Required | Stop, reinstall |
| 5GB+ disk space | Required | Free up space first |
| Internet connection | Required | Establish connection |
| Sudo access | Required | Set up sudo |
| Backup (any type) | Critical | Create backup now |
| Power stability | Recommended | Get UPS if possible |
| POSIX shell | Auto | Always available |

### Green Light to Proceed?

✅ **Ready to upgrade if:**
- [ ] All "Required" items checked
- [ ] At least one backup type created
- [ ] This entire document reviewed
- [ ] Main documentation (Part 1-2) understood

❌ **NOT ready if:**
- [ ] Fedora 41 not installed
- [ ] Less than 5GB disk space (cannot be freed)
- [ ] No internet connection available
- [ ] Sudo access not available

---

## 📄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-18 | Initial comprehensive requirements document |

---

## References

- **Fedora Requirements:** https://docs.fedoraproject.org/
- **DNF Documentation:** https://dnf.readthedocs.io/
- **Hardware Compatibility:** https://fedoraproject.org/wiki/Architectures
- **Network Setup:** https://docs.fedoraproject.org/en-US/fedora/latest/networking-guide/

---

*Last updated: January 18, 2026*  
*Version: 1.0.0*  
*Status: ✅ Current and Verified*
