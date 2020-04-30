#!/usr/bin/python
from traceback import format_exc


class FilterModule(object):
    def filters(self):
        return {
            'inv_init': self.inv_init,
            'inv_meta': self.inv_meta,
            'inv_data': self.inv_data,
            'inv_generic': self.inv_generic,
        }

    def _id(self, ns, type_, id_):
        """
            Returns a service id as formatted in gridinit
            id_ can be a string e.g: 0.1
        """
        return '%s-%s-%s' % (ns, type_, str(id_))

    def _mkpath(self, fmt, mp, ns, service_id):
        """
        Create volume path using the provided format
        Format supports:
        - mp: mountpoint
        - ns: namespace
        - id: service id
        Note: VDO: This code is duped from the openio filter module
        """
        return fmt.format(mp=mp, ns=ns, id=service_id)

    def _loc(self, location, id_=None, loc_custom=False):
        """
            Returns a formatted location
        """
        if location is None:
            return ''
        return location + ('' if loc_custom else str(id_))

    def _register(self, inv, ns, type_, svc):
        try:
            inv['namespaces'][ns]['services'].setdefault(type_, [])
            inv['namespaces'][ns]['services'][type_].append(svc)
        except Exception as e:
            raise Exception('Could not append %s %s %s to inventory: %s' %
                            (ns, type_, svc, format_exc(e)))

    def inv_init(self, inv, ns, params=dict()):
        """ Initialize inventory """
        inv['namespaces'][ns] = dict(
            config=dict(),
            rack=params.get('rack').rstrip('.'),
            localname=params.get('localname'),
            services=dict(),
        )
        return inv

    def inv_meta(self, inv, mounts, params):
        """ Registers metaX services using openio_metadata_mounts """
        ns = params.get('namespace')
        type_ = params.get('type')
        dport = params.get('port')
        loc_custom = params.get('location_custom')
        for k in (('namespace', ns), ('type', type_), ('port', dport)):
            if not k[1]:
                raise Exception('%s required for inventory generation' % k[0])

        for mid, mount in enumerate(mounts):
            if type_ == 'meta0' and mid > 0:
                break
            svc_tpl = dict(
                ip=params.get('ip', ''),
                partition=mount.get('partition', ''),
                volume=mount.get('mountpoint', ''),
                config=params.get('config', {})
            )

            if type_ == 'meta2' and 'meta2_indexes' in mount:
                # Use indexes as reference for id
                for sid in mount['meta2_indexes']:
                    svc = svc_tpl.copy()
                    svc['id'] = self._id(ns, type_, sid)
                    svc['port'] = int(dport) + sid
                    svc['location'] = self._loc(
                        params.get('location'), sid, loc_custom)
                    svc['volume'] = self._mkpath(
                        params.get('volume_fmt'),
                        mount.get('mountpoint', ''),
                        ns, sid)
                    self._register(inv, ns, type_, svc)
            else:
                count = 1
                if type_ == 'meta2':
                    count = mount.get('meta2_count', 1)
                elif type_ == 'meta1':
                    count = mount.get('meta1_count', 1)

                legacy_id = params.get('legacy_id', 0)
                for id_ in range(count):
                    sid = id_ + legacy_id + mid * count
                    svc = svc_tpl.copy()
                    svc['id'] = self._id(ns, type_, sid)
                    svc['port'] = int(dport) + sid
                    svc['location'] = self._loc(
                        params.get('location'), sid, loc_custom)
                    svc['volume'] = self._mkpath(
                        params.get('volume_fmt'),
                        mount.get('mountpoint', ''), ns, sid)
                    self._register(inv, ns, type_, svc)
        return inv

    def inv_data(self, inv, mounts, params):
        """ Registers data services using openio_data_mounts """
        ns = params.get('namespace')
        type_ = params.get('type')
        dport = int(params.get('port', 0)) + int(params.get('legacy_id', 0))
        for k in (('namespace', ns), ('type', type_)):
            if not k[1]:
                raise Exception('%s required for inventory generation' % k[0])

        for mid, mount in enumerate(mounts):
            sid = params.get('legacy_id', 0) + mid
            loc_custom = params.get('location_custom')

            svc = dict(
                id=self._id(ns, type_, sid),
                port=int(dport) + mid if int(dport) > 0 else 0,
                volume=self._mkpath(
                    params.get('volume_fmt'),
                    mount.get('mountpoint', ''),
                    ns, sid),
                ip=params.get('ip', ''),
                partition=mount.get('partition', ''),
                location=self._loc(params.get('location'), mid, loc_custom),
                config=params.get('config', {})
            )
            self._register(inv, ns, type_, svc)

        return inv

    def inv_generic(self, inv, params):
        """ Register a generic service """
        ns = params.get('namespace')
        type_ = params.get('type')
        id_ = params.get('id', 0)
        loc_custom = params.get('location_custom')

        volume = params.get('volume')
        volume_fmt = params.get('volume_fmt')
        mp = params.get('mountpoint')
        if not volume and volume_fmt and mp:
            volume = self._mkpath(
                volume_fmt, mp, ns, id_)

        svc = dict(
            id=self._id(ns, type_, id_),
            port=int(params.get('port', 0)),
            volume=volume,
            ip=params.get('ip', ''),
            partition='',
            role=params.get('role', ''),
            location=self._loc(params.get('location'), id_, loc_custom),
            config=params.get('config', {})
        )
        self._register(inv, ns, type_, svc)
        return inv
