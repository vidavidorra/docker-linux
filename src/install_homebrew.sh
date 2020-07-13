#!/bin/bash
#
# Install Homebrew.
#
# The installation is based on the installation instructions of the Homebrew
# documentation at https://docs.brew.sh/Homebrew-on-Linux.

################################################################################
# Configuration
################################################################################
# Fail on first error.
set -e
# Echo commands.
set -x

################################################################################
# Constants
################################################################################


################################################################################
# Global variables
################################################################################
# renovate: datasource=git-tags depName=https://github.com/Homebrew/brew versioning=semver
HOMEBREW_VERSION='2.4.6'

################################################################################
# Functions
################################################################################
########################################
# Install Homebrew requirements.
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
homebrew::install_requirements() {
  apt-get update

  # Homebrew requirements.
  # See https://docs.brew.sh/Homebrew-on-Linux#linuxwsl-requirements.
  apt-get install -y \
    build-essential \
    curl \
    file \
    git

  # Implicit requirements for `brew tests` and `brew audit`. These are actually
  # requirements for the Nokogiri Ruby package, which is used for those
  # commands.
  # See https://nokogiri.org/tutorials/installing_nokogiri.html#ubuntu-debian
  # and https://discourse.brew.sh/t/brew-tests-fails-on-ubuntu-docker/4770.
  apt-get install -y \
    patch \
    zlib1g-dev \
    liblzma-dev

  # Delete all the apt list files since they're big and get stale quickly. This
  # forces "apt-get update" in dependent images, which is also good. See also
  # https://bugs.launchpad.net/cloud-images/+bug/1699913.
  apt-get clean \
    && rm -rf /var/lib/apt/lists/*
}

########################################
# Install Homebrew.
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
homebrew::install() {
  echo "Installing Homebrew ${HOMEBREW_VERSION}"

  local homebrew_user='linuxbrew'
  useradd -m -s /bin/bash "${homebrew_user}"
  echo "${homebrew_user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

  su - "${homebrew_user}" -c \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

########################################
# Test the Homebrew installation.
# This test will try to install the hello formula and execute it after a
# successful install.
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
homebrew::test() {
  brew install hello
  hello
}

########################################
# Show Homebrew configuration.
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
homebrew::show_config() {
  brew --env
  brew config
}

########################################
# Run Homebrew unit and integration tests.
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
homebrew::run_tests() {
  # Verify the system is ready to brew.
  brew doctor

  # Run the tests.
  brew tests
}

########################################
# Install some generic and useful packages.
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
homebrew::install_packages() {
  brew install \
    gcc \
    git \
    node \
    wget
}

################################################################################
# Main
################################################################################
main() {
  homebrew::install_requirements
  homebrew::install
  homebrew::show_config
  homebrew::test
  homebrew::run_tests
  homebrew::install_packages
}

main "${@}"
