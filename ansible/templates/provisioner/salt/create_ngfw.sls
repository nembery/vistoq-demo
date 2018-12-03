{% set panos_img = 'PA-VM-KVM-8.1.3.qcow2' %}

{% set vm_name = (salt['pillar.get']('vm_name', 'panos-01')) %}

{% set admin_username = (salt['pillar.get']('admin_username', 'admin')) %}
{% set admin_password = (salt['pillar.get']('admin_password', 'admin')) %}

{% set left_bridge = (salt['pillar.get']('left_interface_bridge', 'br1')) %}
{% set right_bridge = (salt['pillar.get']('right_interface_bridge', 'br0')) %}

{% set instance_path = '/opt/instances/' ~ vm_name ~ '.img' %}
{% set bootstrap_path = '/opt/instances/' ~ vm_name ~ '_bootstrap.iso' %}

ensure_left_bridge:
  cmd.run:
    - name: 'brctl show | grep {{ left_bridge }} || brctl addbr {{ left_bridge }}'

ensure_right_bridge:
  cmd.run:
    - name: 'brctl show | grep {{ right_bridge }} || brctl addbr {{ right_bridge }}'

create_domain_template:
  file.managed:
    - name: /var/tmp/{{ vm_name }}.xml
    - source: salt://domain.j2
    - template: jinja
    - defaults:
        vm_name: '{{ vm_name }}'
        instance_path: '{{ instance_path }}'
        bootstrap_path: '{{ bootstrap_path }}'
        left_bridge: '{{ left_bridge }}'
        right_bridge: '{{ right_bridge }}'
    - require:
       - cmd: ensure_left_bridge
       - cmd: ensure_right_bridge

create_image_dir:
  file.directory:
    - name: /opt/images

create_instance_dir:
  file.directory:
    - name: /opt/instances

ensure_latest_image:
  cmd.run:
    - name: gsutil -q cp gs://vistoq-images/{{ panos_img }} /opt/images
    - creates: /opt/images/{{ panos_img }}
    - require:
      - file: create_image_dir

generate_bootstrap_payload:
  file.managed:
    - name: /var/tmp/bootstrap_payload.json
    - source: salt://bootstrap_payload.j2
    - template: jinja
    - context:
        admin_username: {{ admin_username }}
        admin_password: {{ admin_password }}
        vm_name: {{ vm_name }}

remove_stale_bootstrap_iso:
  file.absent:
    - name: {{ bootstrap_path }}

get_bootstrap_iso:
  cmd.run:
    - name: 'curl -X POST -d @/var/tmp/bootstrap_payload.json -H "Content-Type: application/json" http://controller-01:5000/bootstrap_kvm -o {{ bootstrap_path }}'
    - creates: {{ bootstrap_path }}
    - require:
      - file: generate_bootstrap_payload
      - cmd: ensure_latest_image
      - file: create_domain_template
      - file: remove_stale_bootstrap_iso

create_thin_image:
  cmd.run:
   - name: 'qemu-img create -b /opt/images/{{ panos_img }} -f qcow2 {{ instance_path }}'
   - require:
     - file: create_instance_dir

create_domain:
  module.run:
   - name: virt.define_xml_path
   - path: /var/tmp/{{ vm_name }}.xml
   - require:
      - cmd: get_bootstrap_iso

start_domain:
  module.run:
   - name: virt.start
   - vm_: {{ vm_name }}
   - require:
      - module: create_domain
