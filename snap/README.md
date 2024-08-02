snapcraft

# enable QAT on the host
# see enable_vfio.sh

# install in strictly confine mode
# will have all restrictions effective
sudo snap install --dangerous qatengine_1.0_amd64.snap

# devmode
sudo snap install --devmode --dangerous qatengine_1.0_amd64.snap

# run cpa sample; it will work out of the box; probably installing in devmode
# will give full access
# See: Developer mode, or devmode in short, enables developers and users to install snaps
# without enforcing security policies
#
# A strictly confined snap running in devmode will generate log and AppArmor profile output
# associated with the snap, helping snap developers and testers understand access issues and other confinement problems.

# Output:
# audit: type=1326 audit(1722277838.903:6163809): auid=1000 uid=0 gid=0 ses=1006 subj=/usr/lib/snapd/snap-confine pid=1034530 comm="snap-confine" exe="/usr/lib/snapd/snap-confine"
# sig=0 arch=c000003e syscall=317 compat=0 ip=0x76a031f2725d code=0x7ffc0000
# snap-confine is an apparmor profile

# SEE: https://snapcraft.io/docs/debug-snaps#heading--seccomp
# SEE: snappy-debug

sudo qatengine.cpa-sample-code


# Access needs
# Here is the output whzn we run cpa-sample-tool with limited access mode
# Jul 29 18:58:18 curtis-739457 kernel: audit: type=1400 audit(1722279498.103:63718220): apparmor="DENIED" operation="capable" class="cap" profile="/usr/lib/snapd/snap-confine" pid=1041461 comm="snap-confine" capability=12  capname="net_admin"


# Jul 29 18:58:18 curtis-739457 kernel: audit: type=1400 audit(1722279498.103:63718221): apparmor="DENIED" operation="capable" class="cap" profile="/usr/lib/snapd/snap-confine" pid=1041461 comm="snap-confine" capability=38  capname="perfmon"


# QAT application has necessary access permissions if run in -classic mode


# apparmor
# profile: /var/lib/snapd/apparmor/profiles/snap.qatengine.cpa-sample-code
# https://forum.snapcraft.io/t/apparmor-profile-customisation/35780/3
# https://github.com/canonical-web-and-design/tutorials.ubuntu.com/blob/master/tutorials/security/beginning-apparmor-profile-development/beginning-apparmor-profile-development.md


# aa-complain:

Profile:  snap.qatengine.cpa-sample-code
Path:     /dev/qat_adf_ctl
New Mode: owner rw
Severity: unknown

 [1 - owner /dev/qat_adf_ctl rw,]
(A)llow / [(D)eny] / (I)gnore / (G)lob / Glob with (E)xtension / (N)ew / Audi(t) / (O)wner permissions off / Abo(r)t / (F)inish
Adding owner /dev/qat_adf_ctl rw, to profile.

Profile:  snap.qatengine.cpa-sample-code
Path:     /dev/vfio/460
Old Mode: w
New Mode: owner rw
Severity: unknown

 [1 - owner /dev/vfio/460 rw,]
(A)llow / [(D)eny] / (I)gnore / (G)lob / Glob with (E)xtension / (N)ew / Audi(t) / (O)wner permissions off / Abo(r)t / (F)inish
Adding owner /dev/vfio/460 rw, to profile.

Profile:  snap.qatengine.cpa-sample-code
Path:     /sys/kernel/iommu_groups/460/devices/
New Mode: owner r
Severity: 4

 [1 - owner /sys/kernel/iommu_groups/460/devices/ r,]
(A)llow / [(D)eny] / (I)gnore / (G)lob / Glob with (E)xtension / (N)ew / Audi(t) / (O)wner permissions off / Abo(r)t / (F)inish
Adding owner /sys/kernel/iommu_groups/460/devices/ r, to profile.

Profile:  snap.qatengine.cpa-sample-code
Path:     /sys/devices/pci0000:6b/0000:6b:00.1/device
New Mode: owner r
Severity: 4

 [1 - owner /sys/devices/pci0000:6b/0000:6b:00.1/device r,]
(A)llow / [(D)eny] / (I)gnore / (G)lob / Glob with (E)xtension / (N)ew / Audi(t) / (O)wner permissions off / Abo(r)t / (F)inish
Adding owner /sys/devices/pci0000:6b/0000:6b:00.1/device r, to profile.  

Profile:  snap.qatengine.cpa-sample-code
Path:     /sys/devices/pci0000:6b/0000:6b:00.1/vendor
New Mode: owner r
Severity: 4

 [1 - owner /sys/devices/pci0000:6b/0000:6b:00.1/vendor r,]
(A)llow / [(D)eny] / (I)gnore / (G)lob / Glob with (E)xtension / (N)ew / Audi(t) / (O)wner permissions off / Abo(r)t / (F)inish
Adding owner /sys/devices/pci0000:6b/0000:6b:00.1/vendor r, to profile.


# new app profile

  owner /dev/qat_adf_ctl rw,                                                                owner /dev/vfio/460 rw,                                                                   owner /sys/bus/pci/drivers/4xxx/ r,                                                       owner /sys/devices/pci0000:6b/0000:6b:00.1/device r,                                      owner /sys/kernel/iommu_groups/460/devices/ r,                                                    
# disable profile
sudo aa-disable snap.qatengine.cpa-sample-code

# we will get this error when we run cpa-sample-code
ubuntu@curtis-739457:~$ sudo qatengine.cpa-sample-code 
missing profile snap.qatengine.cpa-sample-code.
Please make sure that the snapd.apparmor service is enabled and started

# reload profile
sudo apparmor_parser -r /var/lib/snapd/apparmor/profiles/snap.qatengine.cpa-sample-code
# = it is not working !

# snapd + apparmor
there is a service snapd.apparmor.service
/usr/lib/snapd/snapd-apparmor

snapd tranlate all interfaces to apparmor profiles
for example network-control plug will be translated to apparmor profile

