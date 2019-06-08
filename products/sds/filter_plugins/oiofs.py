#!/usr/bin/python
class FilterModule(object):
    def filters(self):
        return {
            'dict2string': self.dict2string,
            'mounts2nfs': self.mounts2nfs,
            'mounts2samba': self.mounts2samba,
        }

    def dict2string(self, input_dict):
        output_string = ''
        for key, value in input_dict.iteritems():
            output_string += key+'='+value+' '
        return output_string.rstrip()

    def mounts2nfs(self, mounts=[], mount_directory='/tmp'):
        openio_nfs_exports = []
        for mount in mounts:
            if mount.get('export') == 'nfs':
                opts = mount['nfs_exports']
            elif 'nfs' in mount.get('exports', {}): # retrocompatibility
                opts = mount['exports']['nfs']
            else:
                continue

            opts['mountpoint'] = self.mount2mountpoint(mount, mount_directory)

            openio_nfs_exports.append(opts)
        return openio_nfs_exports

    def mounts2samba(self, mounts=None, mount_directory='/tmp'):
        openio_samba_exports = []
        for mount in mounts:
            if mount.get('export') == 'samba':
                opts = mount['samba_exports']
            elif 'samba' in mount.get('exports', {}): # retrocompatibility
                opts = mount['exports']['samba']
            else:
                continue

            opts['path'] = self.mount2mountpoint(mount, mount_directory)

            openio_samba_exports.append(opts)
        return openio_samba_exports

    @staticmethod
    def mount2mountpoint(mount, mount_directory):
        if 'path' in mount:
            return mount['path']

        return '%s/oiofs-%s-%s-%s' % (mount_directory,
                mount['namespace'], mount['account'], mount['container'])
