require 'yaml'
# -*- mode: ruby -*-
# vi: set ft=ruby :

API_VERSION = "2"
vbox_gui = ENV['VAGRANT_VBOX_GUI'] if ENV['VAGRANT_VBOX_GUI']
Vagrant.configure(API_VERSION) do |config|
  # rsync local csi folder on csi image
  config.vm.synced_folder(
    ".", 
    "/csi", 
    type: "rsync",
    rsync__exclude: "./etc/aws/vagrant.yaml",
    rsync__args: ["--progress", "--verbose", "--rsync-path='/usr/bin/sudo /usr/bin/rsync'", "--archive", "--delete", "-z"]
  ) 

  config.vm.provider(:virtualbox) do |vb, override|
    override.vm.box = "ubuntu/xenial64"
    if vbox_gui == "gui"
      vb.gui = true
    else
      vb.gui = false
    end

    yaml_config = YAML.load_file('./etc/virtualbox/vagrant.yaml')
    vb.memory = yaml_config["memory"]
    hostname = yaml_config["hostname"]
    diskMB = yaml_config["diskMB"]
    override.vm.hostname = hostname

    #disk_uuid = ""
    #while disk_uuid == ""
    #  disk_uuid = `VBoxManage list hdds | grep -B 8 "10240 MBytes" | head -n 1 | awk '{print $2}'`.to_s.scrub.strip.chomp
    #  sleep 3
    #end

    #vb.customize ["modifyhd", "#{disk_uuid}", "--resize", "#{diskMB}"]
  end

  config.vm.provider(:aws) do |aws, override|

    override.vm.box = "dummy"

    yaml_config = YAML.load_file('./etc/aws/vagrant.yaml')
    hostname = yaml_config["hostname"]

    #aws_init_script = "#!/bin/bash\necho \"Updating FQDN: #{hostname}\"\ncat /etc/hosts | grep \"#{hostname}\" || sudo sed 's/127.0.0.1/127.0.0.1 #{hostname}/g' -i /etc/hosts\nhostname | grep \"#{hostname}\" || sudo hostname \"#{hostname}\"\nsudo sed -i -e 's/^Defaults.*requiretty/# Defaults requiretty/g' /etc/sudoers\necho 'Defaults:ubuntu !requiretty' >> /etc/sudoers"

    aws.access_key_id = yaml_config["access_key_id"]
    aws.secret_access_key = yaml_config["secret_access_key"]
    aws.keypair_name = yaml_config["keypair_name"]

    aws.ami = yaml_config["ami"]
    aws.block_device_mapping = yaml_config["block_device_mapping"]
    aws.region = yaml_config["region"]
    aws.monitoring = yaml_config["monitoring"]
    aws.elastic_ip = yaml_config["elastic_ip"]
    aws.associate_public_ip = yaml_config["associate_public_ip"]
    aws.private_ip_address = yaml_config["private_ip_address"]
    aws.subnet_id = yaml_config["subnet_id"]
    aws.instance_type = yaml_config["instance_type"]
    aws.iam_instance_profile_name = yaml_config["iam_instance_profile_name"]
    aws.security_groups = yaml_config["security_groups"]
    aws.tags = yaml_config["tags"]
    # Hack for dealing w/ images that require a pty when using sudo and changing hostname
    #aws.user_data = aws_init_script
  
    override.ssh.username = yaml_config["ssh_username"]
    override.ssh.private_key_path = yaml_config["ssh_private_key_path"]
    override.dns.record_sets = yaml_config["record_sets"]
  end

  # install packages after csi image has booted
  config.vm.provision :shell, path: "./vagrant/install/init_env.sh", args: "#{hostname}", privileged: false
  config.vm.provision :shell, path: "./vagrant/update/linux_distribution.sh", args: "", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/rvm.sh", args: "head", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/ruby.sh", args: "", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/csi.rb", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/phantomjs.rb", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/tor.sh", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/burpsuite.sh", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/apache2.sh", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/sipp.sh", privileged: false

  #TODO: populate vbox_gui via etc/virtualbox/vagrant.yaml
  case vbox_gui
    # VirtualBox Section
    when "gui" # GUI
      #TODO: enable devices (e.g. cdrom)
      config.vm.provision :shell, path: "./vagrant/install/terminator.sh", privileged: false
      config.vm.provision :shell, path: "./vagrant/install/firefox.sh", privileged: false
      config.vm.provision :shell, path: "./vagrant/install/chrome.sh", privileged: false
      config.vm.provision :shell, path: "./vagrant/install/lxde.sh", privileged: false
      config.vm.provision :shell, path: "./vagrant/install/drozer.sh", privileged: false
    when "headless" # Headless
      config.vm.provision :shell, path: "./vagrant/install/drozer.sh", privileged: false
  else
    # AWS Section
    config.vm.provision :shell, path: "./vagrant/install/letsencrypt.sh", args: "head", privileged: false
    config.vm.provision :shell, path: "./vagrant/install/openvas.sh", privileged: false
  end

  # Tools
  config.vm.provision :shell, path: "./vagrant/install/jenkins.sh", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/nmap.sh", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/sqlmap.sh", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/arachni.rb", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/metasploit.rb", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/beef.rb", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/scapy.sh", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/wpscan.rb", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/sslyze.sh", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/ssllabs-scan.sh", privileged: false
  config.vm.provision :shell, path: "./vagrant/install/dnsrecon.sh", privileged: false

  # TODO: Convert Scripts Above into Ansible Playbooks
  #config.vm.provision :ansible do |ansible|
  #  ansible.playbook = "./ansible/site.yaml"
  #  ansible.verbose = "vvvv" # Useful for debugging
  #  ansible.groups = {
  #      "dev_servers" => ["default"]
  #  }
  #end
end
