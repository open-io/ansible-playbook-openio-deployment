# Copyright (C) 2020 OpenIO SAS

## https://github.com/ansible/ansible/issues/45315

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.plugins.action import ActionBase
from ansible.parsing.yaml.objects import AnsibleMapping,AnsibleUnicode,AnsibleSequence
from ansible.errors import AnsibleError
from ansible.utils.display import Display

import ansible.constants as C

display = Display()

#
# Usage:
#
# tasks:
#   - name: "Set default variables"
#     oio_default_variables:
#       settings: "settings"
#       variables:
#         - myvar1
#
# for each variables that are defined in the settings variable,
# set the corresponding variable if not already set. If it's a mapping,
# then merge actual value and default value.
#
# if the variables parameter is set, then only the listed variables will
# be set to default
#
# Here is a sample of the settings variable:
#
#{
#  "settings": [
#    {
#      "name": "OpenIO user UID",
#      "variable": "default_openio_user_openio_uid",
#      "default": 120,
#      "type": "number",
#      "hidden": true,
#      "readonly": true,
#      "group": "openio",
#      "section": "general"
#    }
#}

class ActionModule(ActionBase):

    TRANSFERS_FILES = False

    #
    # Update the local variables used by jinja2 templating
    #
    def _update_locals(self, key, value):
        _locals = self._templar.available_variables
        _locals[key] = value
        self._templar.available_variables = _locals

    #
    # Run the action
    #
    def run(self, tmp=None, task_vars=None):
        if task_vars is None:
            task_vars = dict()

        result = super(ActionModule, self).run(tmp, task_vars)
        del tmp  # tmp no longer has any effect

        facts = dict()
        ansible_variables = getattr(self._templar, '_available_variables', {})
        changed = False

        # default parameters
        variables = self._task.args.pop('variables', [])
        settings = self._task.args.pop('settings', 'settings')

        if type(variables) != list:
            raise AnsibleError("'variables' must be an array (but is '%s')", type(variables))

        if settings not in ansible_variables or type(ansible_variables[settings]) != AnsibleSequence:
            raise AnsibleError("settings variable (%s) not found ot not good type" % settings)

        # default to all variables and select only them with default values
        # as we don't necessarly want to have default value for each variable
        if len(variables) == 0:
            variables = [x['variable'] for x in ansible_variables[settings] if 'default' in x]

        if settings in variables:
            raise AnsibleError("The settings variables (%s) can't be set inside itself, it would be incest ... gnurf" % settings)

        settings = ansible_variables[settings]
        not_founds = []

        for var in variables:
            is_mapping = (var in ansible_variables and type(ansible_variables[var]) == AnsibleMapping)

            # don't default already defined variables that are not mappings
            # as mappings will be combined
            if var in ansible_variables and not is_mapping:
                continue

            # search for the variable in the settings variables (array)
            dict_d = next((dict_d for dict_d in settings if dict_d['variable'] == var), None)

            # ensure the default variable exists in settings
            if not dict_d:
                not_founds.append(var)
                continue

            # ignore without errors default variable without default value
            if 'default' not in dict_d:
                display.warning("variable '%s' has not default, skipping" % var)
                continue

            # set a local variable for jinja2 to access the default variable
            self._update_locals('_default_' + var, dict_d['default'])

            if is_mapping:
                if type(dict_d['default']) != AnsibleMapping:
                  display.warning("variable '%s' is a mapping whereas its defaults is not a mapping (%s), skipping" % (var, type(dict_d['default'])))
                  continue

                facts[var] = self._templar.template("{{ lookup('vars', '_default_%s') | combine(lookup('vars', '%s')) }}" % (var, var))
            else:
                facts[var] = self._templar.template("{{ lookup('vars', '_default_%s') }}" % var)

            if var in facts:
                # update the local variable with the generated value in order
                # for this variable to be accessible from next variables if necessary
                self._update_locals(var, facts[var])
                changed = True

        if len(not_founds) > 0:
            result['failed'] = True
            result['msg'] = "The following default variables were not defined:\n" + "\n".join(not_founds)
            return result

        result['changed'] = changed
        result['ansible_facts'] = facts
        return result
