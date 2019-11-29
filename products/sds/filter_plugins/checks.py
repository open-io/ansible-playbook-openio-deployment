#!/usr/bin/python
import six

class FilterModule(object):
    def filters(self):
        return {
            'check_uid': self.check_uid,
            'check_gid': self.check_gid,
        }

    def check_uid(self, getent, user, uid):
        return self._check(getent, user, uid, 1)

    def check_gid(self, getent, group, gid):
        return self._check(getent, group, gid, 2)

    def _check(self, getent, entity, id_, mode):
        """ Check that a specific UID/GID is free
            or is assigned to a specific entity
        """
        type_ = 'user' if mode == 1 else 'group'
        id_name = 'UID' if mode == 1 else 'GID'
        for k, v in six.iteritems(getent):
            if k == entity and int(v[mode]) != int(id_):
                raise Exception(
                    "%s '%s' already exists under a different %s: %d" %
                    (type_, entity, id_name, int(v[mode])))
            elif k != entity and int(v[mode]) == int(id_):
                raise Exception(
                    "%s '%s' already has the requested %s for user '%s': %d" %
                    (type_, k, id_name, entity, int(id_)))
        return True
