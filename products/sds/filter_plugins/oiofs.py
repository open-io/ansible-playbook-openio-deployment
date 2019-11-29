#!/usr/bin/python

HUMAN_UNITS = {
    'KB': 1024,
    'MB': 1048576,
    'GB': 1073741824,
    'TB': 1099511627776,
}

class FilterModule(object):

    def filters(self):
        return {
            'dict2string': self.dict2string,
            'mounts2nfs': self.mounts2nfs,
            'mounts2samba': self.mounts2samba,
            'smallest_device': self.smallest_device,
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

    def smallest_device(self, oiofs_cache_devices, ansible_devices={}, ansible_mounts={}):
        smallest_device = ""
        smallest_size = 0

        for device in oiofs_cache_devices:
            if ansible_devices.get(device.split('/')[-1]):  ## block device
                human_size = ansible_devices[device.split('/')[-1]]['size']
                bytes_size = int(float(human_size.split()[0])) * HUMAN_UNITS[human_size.split()[1]]
            else:  # mount
                bytes_size = next(item["size_total"] for item in ansible_mounts if item["device"] == device)

            if smallest_size == 0 or bytes_size < smallest_size:
                smallest_size = bytes_size
                smallest_device = device
        return smallest_device
