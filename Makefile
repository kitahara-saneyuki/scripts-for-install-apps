dc=docker-compose
user_name="kitahara-saneyuki"
user_email="edwarddwarf1999@gmail.com"
SHELL := /bin/bash

init:
	git config --global user.name $(user_name)
	git config --global user.email $(user_email)

docker:
	sudo apt-get -y install lsb-release
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --batch --yes
	echo \
		"deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
		$$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get -y update
	sudo apt-get -y install docker-ce docker-ce-cli containerd.io
	sudo usermod -G docker -a $(USER)
	sudo chmod 666 /var/run/docker.sock
	sudo /etc/init.d/docker start

golang:
	wget -qO https://go.dev/dl/go1.21.2.linux-amd64.tar.gz
	sudo tar -C /usr/local -xzf go1.21.2.linux-amd64.tar.gz
	echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc

kubectl:
	curl -LO "https://dl.k8s.io/release/$$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$$(dpkg --print-architecture)/kubectl"
	curl -LO "https://dl.k8s.io/$$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$$(dpkg --print-architecture)/kubectl.sha256"
	echo "$$(cat kubectl.sha256) kubectl" | sha256sum --check
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	rm kubectl kubectl.sha256

helm:
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
	chmod +x get_helm.sh
	./get_helm.sh
	rm get_helm.sh

vscodium:
	sudo wget https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg -O /usr/share/keyrings/vscodium-archive-keyring.asc
	echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.asc ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
	sudo apt update
	sudo apt install codium codium-insiders	
	echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
	cat /proc/sys/fs/inotify/max_user_watches

rust:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain=nightly --component rls rust-analysis rust-src

signal:
	wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
	cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
	sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
	sudo apt update && sudo apt install signal-desktop
	rm signal-desktop-keyring.gpg

dbeaver:
	sudo apt update
	sudo apt -y install default-jdk
	wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
	echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
	sudo apt update
	sudo apt install dbeaver-ce

yarn:
	sudo apt-get update
	sudo apt-get install -y ca-certificates curl gnupg
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
	echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
	sudo apt-get install -y nodejs build-essential
	sudo npm install -g npm@latest
	sudo npm install -g yarn
	sudo npm install -g create-react-app

lens:
	curl -fsSL https://downloads.k8slens.dev/keys/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/lens-archive-keyring.gpg > /dev/null
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/lens-archive-keyring.gpg] https://downloads.k8slens.dev/apt/debian stable main" | sudo tee /etc/apt/sources.list.d/lens.list > /dev/null
	sudo apt update
	sudo apt install lens

ruby:
	sudo apt-get update 
	sudo apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev
	rm -rf ~/.rbenv
	git clone https://github.com/rbenv/rbenv.git ~/.rbenv
	echo 'export PATH=${HOME}/.rbenv/bin:$$PATH' >> ~/.bashrc
	echo 'eval "rbenv init -"' >> ~/.bashrc
	git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
	echo 'export PATH=${HOME}/.rbenv/plugins/ruby-build/bin:$$PATH' >> ~/.bashrc
	${HOME}/.rbenv/bin/rbenv install $$(${HOME}/.rbenv/bin/rbenv install -l | grep -v - | tail -1)
	${HOME}/.rbenv/bin/rbenv global $$(${HOME}/.rbenv/bin/rbenv install -l | grep -v - | tail -1)
	echo 'export PATH=${HOME}/.rbenv/versions/$$(${HOME}/.rbenv/bin/rbenv install -l | grep -v - | tail -1)/bin:$$PATH' >> ~/.bashrc

fprintd:
	sudo apt remove fprintd
	sudo apt install -y software-properties-common
	sudo add-apt-repository ppa:uunicorn/open-fprintd
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8D4C774BA6D18F90
	sudo apt-get update
	sudo apt install -y open-fprintd fprintd-clients python3-validity
	sudo systemctl start python3-validity
	sudo systemctl enable open-fprintd-resume open-fprintd-suspend

miniconda:
	curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg
	sudo install -o root -g root -m 644 conda.gpg /usr/share/keyrings/conda-archive-keyring.gpg
	gpg --keyring /usr/share/keyrings/conda-archive-keyring.gpg --no-default-keyring --fingerprint 34161F5BF5EB1D4BFBBB8F0A8AEB4F8B29D82806
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/conda-archive-keyring.gpg] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" | sudo tee -a /etc/apt/sources.list.d/conda.list
	sudo apt update
	sudo apt install conda
	echo "source /opt/conda/etc/profile.d/conda.sh" > ~/.bashrc
