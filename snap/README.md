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
