#!/usr/bin/python

import json


class FilterModule(object):
    def filters(self):
        return {
            'make_sequence': self.make_sequence,
            'valid_start': self.valid_start
        }

    def valid_start(self, out, inst):
        """
            Verify that the restart is valid
            Service must be up and not have died in between
        """
        out = json.loads(out)
        for i, svc in enumerate(out):
            if svc["status"] != "UP" or inst["died"][i] != svc["#died"]:
                return False
        return True

    def make_sequence(self, hosts, ns, services, hostvars, policy_one):
        """
            Create a restart sequence to be run against all services
            on all hosts, depending on the services on each node and
            the defined restart policy
        """
        out = []
        policy_one = policy_one.split(',')
        for stype in services.split(','):
            for host in hosts:
                s_out = []
                for l in json.loads(hostvars[host]['services'].get('stdout', "[]")):
                    if l['key'].startswith('%s-%s-' % (ns, stype)) and\
                       l['status'] == 'UP':
                        s_out.append(l)
                if stype in policy_one:
                    for target in s_out:
                        if target["key"] == "":
                            continue
                        out.append(dict(
                            host=host,
                            target=target['key'],
                            died=[int(target['#died']), ]
                        ))
                else:
                    if " ".join([target['key'] for target in s_out]) == "":
                        continue
                    out.append(dict(
                        host=host,
                        target=" ".join([target['key'] for target in s_out]),
                        died=[int(target['#died']) for target in s_out]
                    ))
        return out
