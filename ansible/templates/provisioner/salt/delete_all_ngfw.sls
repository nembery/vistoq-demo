{% set vms = salt['virt.list_active_vms']() %}
{% for vm in vms %}

delete_vm_{{ vm }}:
 module.run:
   - name: virt.purge
   - vm_: {{ vm }}

{% endfor %}