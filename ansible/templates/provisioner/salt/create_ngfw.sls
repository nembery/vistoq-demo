
create_domain_template:
  file.managed:
    - name: /var/tmp/domain.xml
    - source: salt://domain.j2
    - template: jinja

create_image_dir:
  file.directory:
    - name: /opt/images

ensure_latest_image:
  cmd.run:
    - name: gsutil -q cp gs://vistoq-images/PA-VM-KVM-8.1.3.qcow2 /opt/images
    - creates: /opt/images/PA-VM-KVM-8.1.3.qcow2

generate_bootstrap_payload:
  file.managed:
    - name: /var/tmp/bootstrap_payload.json
    - source: salt://bootstrap_payload.j2
    - template: jinja

get_bootstrap_iso:
  cmd.run:
    - name: curl -X POST -d @/var/tmp/bootstrap_payload.json http://controller-01:5000/bootstrap_kvm -o /var/tmp/pan-bootstrap.iso
    - creates: /var/tmp/pan-bootstrap.iso

create_domain:
  module.run:
   - name: virt.create_xml_path
   - path: /var/tmp/domain.xml

