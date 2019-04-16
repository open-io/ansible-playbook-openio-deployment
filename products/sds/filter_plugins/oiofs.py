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
            if 'exports' in mount:
                if 'nfs' in mount['exports']:
                    path = (mount['path'] if 'path' in mount else mount_directory + '/oiofs-'
                            + mount['namespace'] + '-' + mount['account']
                            + '-' + mount['container'])
                    opts = mount['exports']['nfs']
                    opts['mountpoint'] = path

                    openio_nfs_exports.append(opts)
        return openio_nfs_exports

    def mounts2samba(self, mounts=None, mount_directory='/tmp'):
        openio_samba_exports = []
        for mount in mounts:
            if 'exports' in mount:
                if 'samba' in mount['exports']:
                    path = (mount['path'] if 'path' in mount else mount_directory + '/oiofs-'
                            + mount['namespace'] + '-' + mount['account'] + '-'
                            + mount['container'])
                    opts = mount['exports']['samba']
                    opts['path'] = path

                    openio_samba_exports.append(opts)
        return openio_samba_exports
