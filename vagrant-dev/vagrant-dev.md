# [fit] Developing Betamax with Vagrant

-

## [fit] Joe Corcoran · [corcoran.io](http://corcoran.io) · [@josephcorcoran](http://twitter.com/josephcorcoran)

---

# Vagrant

[vagrantup.com](https://www.vagrantup.com/)

---

# Vagrant

```ruby
Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'
end
```

---

# Vagrant

```ruby
Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.provision 'bashrc', type: 'file',
                                source: '~/.bashrc',
                                destination: '/home/vagrant/.bashrc'
end
```

---

# Vagrant

```ruby
Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.provision 'bashrc', type: 'file',
                                source: '~/.bashrc',
                                destination: '/home/vagrant/.bashrc'
  config.vm.provision 'hello', type: 'shell', inline: 'echo "hello"'
end
```

---

# Vagrant

```
$ vagrant up
```

---

# Vagrant

```
$ vagrant halt
```

```
$ vagrant destroy
```

```
$ vagrant reload
```

```
$ vagrant provision
```

```
$ vagrant provision --provision-with hello
```

---

# Base box

[github.com/tape-tv/betamax-box](https://github.com/tape-tv/betamax-box)

---

# Base box

* `build-essential`
* Git
* Python and `awscli`
* Postgresql
* Node.js
* Redis
* `ruby-install` and `chruby`

---

# Base box

[github.com/tape-tv/betamax-box](https://github.com/tape-tv/betamax-box) -> boxes.tape.tv

---

# Betamax

Using the base box

```ruby
Vagrant.configure(2) do |config|
  config.vm.box = 'http://boxes.tape.tv/betamax-v0.2.1.box'
  # ...
end
```

---

# Betamax

Networking

```ruby
Vagrant.configure(2) do |config|
  config.vm.box = 'http://boxes.tape.tv/betamax-v0.2.1.box'
  config.vm.network 'private_network', ip: '192.168.66.100'
  config.ssh.forward_agent = true
  # ...
end
```

---

# Betamax

## NFS vs rsync

* NFS is generally better
* No file system events on the guest machine

---

# Betamax

## NFS vs rsync

* NFS is generally better
* No file system events on the guest machine

---

# Betamax

## NFS vs rsync

* NFS is generally better
* No file system events on the guest machine
* `rsync-gatling-rsync`

---

# Betamax

```
$ vagrant ssh
```

---

# Betamax

```
$ vagrant ssh
```

```
$ cd /betamax
```

---

# Betamax

```
$ vagrant ssh
```

```
$ cd /betamax
```

```
$ source setup.sh
```

---

# Betamax

```
$ vagrant ssh
```

```
$ cd /betamax
```

```
$ source setup.sh
```

```
$ ./database.sh
```

---

# Thanks!

More info at [betamax/vagrant.md](https://github.com/tape-tv/betamax/blob/master/vagrant.md)
