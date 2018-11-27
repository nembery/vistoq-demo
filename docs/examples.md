
# Building Vistoq Demo on Locally

## Requirements

* VMWare [Fusion Homepage](https://www.vmware.com/products/fusion.html)
* packer [Packer Homepage](https://www.packer.io/intro/) 

## Usage

```bash

packer build -on-error=abort packer/vmware/vistoq-controller.json
packer build -on-error=abort packer/vmware/vistoq-compute.json

```

# Example CLI

```bash
salt compute-01\* state.apply create_ngfw pillar='{"vm_name":"test02","left_interface_bridge":"br0","right_interface_bridge":"br1","admin_username":"admin","admin_password":"test123"}'
```

