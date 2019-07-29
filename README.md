# Drone SSH debugging plugin
This is a plugin for [Drone CI](https://drone.io/) to enable remote build debugging and monitoring over SSH.

Since Drone build runners do not expose their containers' open ports to the public, Serveo is used as a jump box for
forwarding SSH connections. This allows the plugin to work in any build environment with Internet access, including
the hosted [Drone Cloud](https://cloud.drone.io/) service.

## Setup
Add the following step to the beginning of your pipeline:

```yaml
  - name: start-debug-server
    image: kdrag0n/drone-ssh-debug:latest
    detach: true

    settings:
      authorized_keys:
        # authorized_keys for SSH debug server in ssh_authorized_keys secret
        from_secret: ssh_authorized_keys

    when:
      event:
        exclude:
          - pull_request
```

You will then need to create a list of SSH keys that are authorized to log into the server and save the list as a secret
named `ssh_authorized_keys` on Drone. The standard SSH authorized_keys format is used. Password authentication is not
currently supported due to potential security concerns.

After the step has been added and the authorized_keys secret has been populated, check the output of the
`start-debug-server` step for the command to use for connecting to the SSH server. A unique SSH hostname is generated
for each build based on Drone's environment variables.

### Waiting after failed builds
Optionally, if you want failed builds to pause at the end for a configurable amount of time for a quick post-mortem
debugging session, you may add the following step at the end:

```yaml
  - name: wait_for_debug
    image: alpine

    environment:
      # Amount of time to wait for debugging
      # This is intended to serve as a brief preliminary analysis, not a
      # full-fledged post-mortem analysis session
      DEBUG_TIME: 2m

    commands:
      - sleep $DEBUG_TIME

    when:
      status:
        - failure
      event:
        exclude:
          - pull_request
```

Adjust the wait time (`DEBUG_TIME`) as desired.
