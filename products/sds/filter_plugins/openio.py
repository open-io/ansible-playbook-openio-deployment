class FilterModule(object):
    def filters(self):
        return {
            'dict_to_tempauth': self.dict_to_tempauth,
        }

    def dict_to_tempauth(self, users):
        usr = dict()

        for user in users:
            key = 'user_' + user['name'].replace(':', '_')
            value = user['password'] + ''.join(' .' + role for role in user['roles'])
            usr[key] = value
        return usr
