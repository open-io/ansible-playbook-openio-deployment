#!/usr/bin/python
import re
from six.moves import map


class FilterModule(object):
    def filters(self):
        return {
            'dict_to_tempauth': self.dict_to_tempauth,
            'join_by': self.join_by,
            'my_zk_conf_from_string': self.my_zk_conf_from_string,
            'mkpath': self.mkpath,
            'mkpaths': self.mkpaths,
        }

    def mkpaths(self, fmt, ns, meta2):
        """
        Invoke mkpath on a meta2 list, returning the resulting formatted paths
        """
        return [self.mkpath(
            fmt, svc['mountpoint'], ns, svc['id']) for svc in meta2]

    def mkpath(self, fmt, mp, ns, service_id):
        """
        Create volume path using the provided format
        Format supports:
        - mp: mountpoint
        - ns: namespace
        - id: service id
        """
        return fmt.format(mp=mp, ns=ns, id=service_id)

    def dict_to_tempauth(self, users):
        usr = dict()

        for user in users:
            key = 'user_' + user['name'].replace(':', '_')
            value = user['password'] + ''.join(' .' + role for role in user['roles'])
            usr[key] = value
        return usr

    def join_by(self, mylist=[], group_by=3, D=',', d=';'):
        list_grouped_by_comma=[]
        if len(mylist) % group_by == 0:
            for i in range(int(len(mylist) / group_by)):
                list_grouped_by_comma.append(D.join(map(str, mylist[(i * group_by):(i * group_by + group_by)])))

        return d.join(map(str, list_grouped_by_comma))

    def my_zk_conf_from_string(self, zk_string="", my_ip='127.0.0.1', D=',', d=';', zk_port=6005):
        res_list = []
        # convert in a list of lists
        my_list = [i.split(D) for i in zk_string.split(d)]
        for trio in my_list:
            # remove port
            addresses = [re.sub(":" + str(zk_port) + "$", "", i) for i in trio]
            if my_ip in addresses:
                for idx, addr in enumerate(addresses):
                    res_list.append({'host': 'node' + str(idx+1), 'ip': addr, 'id': idx + 1})
        return res_list
