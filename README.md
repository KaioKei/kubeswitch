# kubeswitch

A tiny tool to switch between kubeconfig files.  
It manages `~/.kube/config` symbolic link to switch from a kubeconfig to an other.

This tool is suited to work alongside frameworks using `~/.kube/config` only.  
Use `KUBECONFIG="$HOME/.kube/config1:$HOME/.kube/config2` otherwise.

## Usage

```sh
./bin/kubeswitch -s myconfigname
```
