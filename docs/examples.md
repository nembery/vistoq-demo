# Example CLI

```bash
salt compute-01\* state.apply create_ngfw pillar='{"vm_name":"test02","left_interface_bridge":"br0","right_interface_bridge":"br1","admin_username":"admin","admin_password":"test123"}'
```

