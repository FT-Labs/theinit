pkgname=theinit
pkgver=$(make version)
pkgrel=1
pkgdesc="Modular initramfs image creation utility"
arch=(any)
url="https://github.com/FT-Labs/theinit"
license=('GPL')
groups=('base')
conflicts=('theinit')
provides=("theinit=$pkgver" "initramfs")
depends=('theinit-busybox>=1.19.4-2' 'kmod' 'util-linux>=2.23' 'libarchive' 'coreutils'
         'awk' 'bash' 'binutils' 'findutils' 'grep' 'filesystem>=2011.10-1' 'systemd' 'zstd' 'lshw' 'kexec-tools' 'cpio')
makedepends=('asciidoc' 'git' 'sed')
optdepends=('gzip: Use gzip compression for the initramfs image'
            'xz: Use lzma or xz compression for the initramfs image'
            'bzip2: Use bzip2 compression for the initramfs image'
            'lzop: Use lzo compression for the initramfs image'
            'lz4: Use lz4 compression for the initramfs image'
            'mktheinit-nfs-utils: Support for root filesystem on NFS')
backup=(etc/theinit.conf)

package() {
  make -C "$startdir" DESTDIR="$pkgdir" install
}
